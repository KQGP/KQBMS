#include <WiFi.h>
#include <ESPmDNS.h>
#include <NimBLEDevice.h>
#include <algorithm>
#include <cctype>
#include <string>

const char* WIFI_SSID  = "KQP";
const char* WIFI_PASS  = "shy72@_5hs";

const char* BMS_NAME   = "KQB";
const char* BMS_MAC    = "A5:C2:37:51:BC:F8";

const uint16_t TCP_PORT   = 3333;
const char*    MDNS_NAME  = "kqbms-bridge";

#define BLE_SCAN_DURATION_MS 10000UL

#define SCAN_DEBUG 0

#define STATUS_LED_PIN 2

#define SEND_INIT_HANDSHAKE 1

#define ALLOW_JBD_AUTODETECT 1

static const char* JBD_SERVICE_UUID = "0000ff00-0000-1000-8000-00805f9b34fb";
static const char* JBD_CHAR_RX      = "0000ff01-0000-1000-8000-00805f9b34fb";
static const char* JBD_CHAR_TX      = "0000ff02-0000-1000-8000-00805f9b34fb";

WiFiServer tcpServer(TCP_PORT);
WiFiClient tcpClient;

NimBLEClient* pBLEClient = nullptr;
NimBLERemoteCharacteristic* pCharRx = nullptr;
NimBLERemoteCharacteristic* pCharTx = nullptr;

volatile bool bmsConnected = false;
bool wifiOk = false;

uint32_t lastBleAttempt = 0;
uint32_t bleBackoffMs = 0;

enum LedState { LED_WIFI_SEARCH, LED_BMS_SEARCH, LED_CONNECTED };
LedState ledState = LED_WIFI_SEARCH;

void updateLed() {
#if STATUS_LED_PIN >= 0
  static uint32_t lastToggle = 0;
  static bool on = false;
  LedState want;
  if (!wifiOk)            want = LED_WIFI_SEARCH;
  else if (!bmsConnected) want = LED_BMS_SEARCH;
  else                    want = LED_CONNECTED;

  switch (want) {
    case LED_WIFI_SEARCH:
      if (millis() - lastToggle > 80) { on = !on; lastToggle = millis(); }
      break;
    case LED_BMS_SEARCH:
      if (millis() - lastToggle > 300) { on = !on; lastToggle = millis(); }
      break;
    case LED_CONNECTED:
      on = true;
      break;
  }
  digitalWrite(STATUS_LED_PIN, on ? HIGH : LOW);
#endif
}

class ClientCallbacks : public NimBLEClientCallbacks {
  void onConnect(NimBLEClient* pClient) override {
    Serial.printf("[BLE] Connected, MTU=%d\n", pClient->getMTU());
  }
  void onDisconnect(NimBLEClient* pClient, int reason) override {
    Serial.printf("[BLE] Disconnected, reason=%d\n", reason);
    bmsConnected = false;
    if (tcpClient && tcpClient.connected()) tcpClient.stop();
  }
};
static ClientCallbacks clientCB;

void notifyCB(NimBLERemoteCharacteristic* pChar, uint8_t* data,
              size_t len, bool isNotify) {
  if (tcpClient && tcpClient.connected()) {
    tcpClient.write(data, len);
    tcpClient.flush();
  }
}

class ScanCallbacks : public NimBLEScanCallbacks {
 public:
  volatile bool targetFound = false;
  NimBLEAddress foundAddress{};

  void onResult(const NimBLEAdvertisedDevice* pDevice) override {
    std::string name = pDevice->getName();
    std::string addr = pDevice->getAddress().toString();
    int rssi = pDevice->getRSSI();

#if SCAN_DEBUG
    Serial.printf("[BLE] Found: \"%s\" %s RSSI=%d\n",
                  name.c_str(), addr.c_str(), rssi);
#endif

    if (targetFound) return;

    if (strlen(BMS_NAME) > 0 && name == BMS_NAME) {
      takeMatch("name", pDevice);
      return;
    }

    std::string addrLower = toLower(addr);
    std::string macLower = toLower(std::string(BMS_MAC));
    if (strlen(BMS_MAC) > 0 && addrLower == macLower) {
      takeMatch("mac", pDevice);
      return;
    }

#if ALLOW_JBD_AUTODETECT
    static const char* kJbdPrefixes[] = {
      "JBD-", "DWF-", "LSG-", "SX1", "SBL-", "OGR-", "TZ-H"
    };
    if (!name.empty()) {
      for (const char* prefix : kJbdPrefixes) {
        if (name.rfind(prefix, 0) == 0) {
          takeMatch("jbd-autodetect", pDevice);
          return;
        }
      }
    }
#endif
  }

 private:
  void takeMatch(const char* rule, const NimBLEAdvertisedDevice* pDevice) {
    targetFound = true;
    foundAddress = pDevice->getAddress();
    Serial.printf("[BLE] Matched by %s: \"%s\" %s\n",
                  rule,
                  pDevice->getName().c_str(),
                  pDevice->getAddress().toString().c_str());
  }

  static std::string toLower(std::string s) {
    std::transform(s.begin(), s.end(), s.begin(),
                   [](unsigned char c) { return std::tolower(c); });
    return s;
  }
};

static ScanCallbacks scanCB;

void ensureWifi() {
  if (WiFi.status() == WL_CONNECTED) {
    if (!wifiOk) {
      wifiOk = true;
      Serial.printf("[NET] WiFi connected, IP: %s\n",
                    WiFi.localIP().toString().c_str());
      Serial.printf("[NET] App can connect to %s:%u or %s.local:%u\n",
                    WiFi.localIP().toString().c_str(), TCP_PORT, MDNS_NAME, TCP_PORT);
    }
    return;
  }

  wifiOk = false;
  bmsConnected = false;
  Serial.printf("[NET] Connecting to WiFi \"%s\"...\n", WIFI_SSID);
  WiFi.mode(WIFI_STA);
  WiFi.setAutoReconnect(true);
  WiFi.begin(WIFI_SSID, WIFI_PASS);

  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 40) {
    delay(500);
    updateLed();
    attempts++;
  }

  if (WiFi.status() == WL_CONNECTED) {
    wifiOk = true;
    Serial.printf("[NET] WiFi connected, IP: %s\n",
                  WiFi.localIP().toString().c_str());

    if (MDNS.begin(MDNS_NAME)) {
      MDNS.addService("kqbms", "tcp", TCP_PORT);
      Serial.printf("[NET] mDNS registered: %s.local (_kqbms._tcp:%u)\n",
                    MDNS_NAME, TCP_PORT);
    } else {
      Serial.println("[NET] mDNS registration failed");
    }
  } else {
    Serial.println("[NET] WiFi connection failed, will retry");
  }
}

bool connectToBms() {
  Serial.println("[BLE] Scanning for BMS...");

  NimBLEScan* pScan = NimBLEDevice::getScan();
  pScan->setActiveScan(true);
  pScan->setInterval(97);
  pScan->setWindow(37);
  scanCB.targetFound = false;
  pScan->setScanCallbacks(&scanCB, false);

  NimBLEScanResults results = pScan->getResults(BLE_SCAN_DURATION_MS, false);
  Serial.printf("[BLE] Scan done, %d device(s) seen\n", results.getCount());

  if (!scanCB.targetFound) {
    pScan->clearResults();
    Serial.printf("[BLE] No match this scan (want name=\"%s\" or MAC %s)\n",
                  BMS_NAME, BMS_MAC);
    Serial.println("[BLE] ^ Check the \"Found:\" list above - if your battery");
    Serial.println("[BLE]   shows a different name/address, put that into the");
    Serial.println("[BLE]   BMS_NAME / BMS_MAC config at the top of this sketch.");
    return false;
  }

  NimBLEAddress target = scanCB.foundAddress;
  pScan->clearResults();

  Serial.printf("[BLE] Connecting to %s...\n", target.toString().c_str());

  if (!pBLEClient) pBLEClient = NimBLEDevice::createClient();
  pCharRx = nullptr;
  pCharTx = nullptr;
  pBLEClient->setClientCallbacks(&clientCB, false);
  pBLEClient->setConnectionParams(12, 24, 0, 100);
  pBLEClient->setConnectTimeout(10000);

  if (!pBLEClient->connect(target)) {
    Serial.println("[BLE] Connection failed");
    return false;
  }

  NimBLERemoteService* pSvc = pBLEClient->getService(JBD_SERVICE_UUID);
  if (!pSvc) {
    Serial.println("[BLE] Service ff00 not found");
    pBLEClient->disconnect();
    return false;
  }

  pCharRx = pSvc->getCharacteristic(JBD_CHAR_RX);
  pCharTx = pSvc->getCharacteristic(JBD_CHAR_TX);
  if (!pCharRx || !pCharTx) {
    Serial.println("[BLE] Characteristics ff01/ff02 not found");
    pBLEClient->disconnect();
    return false;
  }

  if (!pCharRx->subscribe(true, notifyCB)) {
    Serial.println("[BLE] Subscribe to notifications failed");
    pBLEClient->disconnect();
    return false;
  }

#if SEND_INIT_HANDSHAKE
  const uint8_t initCmd[] = {0xFF, 0xAA, 0x15, 0x01, 0x16};
  pCharTx->writeValue(initCmd, sizeof(initCmd), false);
  delay(300);
#endif

  Serial.println("[BLE] BMS connected - tunnel is live!");
  bmsConnected = true;
  bleBackoffMs = 0;
  return true;
}

size_t bleChunkSize() {
  size_t chunk = 20;
  if (pBLEClient && pBLEClient->isConnected()) {
    uint16_t mtu = pBLEClient->getMTU();
    if (mtu >= 23) chunk = mtu - 3;
  }
  return chunk;
}

void forwardToBle(uint8_t* data, size_t len) {
  if (!bmsConnected || !pCharTx) return;
  size_t chunkMax = bleChunkSize();
  size_t offset = 0;
  while (offset < len) {
    size_t n = (len - offset) < chunkMax ? (len - offset) : chunkMax;
    pCharTx->writeValue(data + offset, n, false);
    offset += n;
  }
}

void serveTcp() {
  if (tcpClient && tcpClient.connected()) {
    while (tcpClient.available()) {
      uint8_t buf[512];
      int n = tcpClient.read(buf, sizeof(buf));
      if (n <= 0) break;
      forwardToBle(buf, (size_t)n);
    }
    return;
  }

  WiFiClient newClient = tcpServer.available();
  if (newClient) {
    Serial.printf("[TCP] Client connected: %s\n",
                  newClient.remoteIP().toString().c_str());
    tcpClient.stop();
    tcpClient = newClient;
    tcpClient.setTimeout(50);
  }
}

void setup() {
  Serial.begin(115200);
  Serial.println("\n\n=== KQBMS WiFi<->BLE Bridge ===");

#if STATUS_LED_PIN >= 0
  pinMode(STATUS_LED_PIN, OUTPUT);
  digitalWrite(STATUS_LED_PIN, LOW);
#endif

  NimBLEDevice::init("KQBMS-Bridge");

  ensureWifi();
  tcpServer.begin(TCP_PORT);
  Serial.printf("[TCP] Server listening on port %u\n", TCP_PORT);
}

void loop() {
  updateLed();

  if (WiFi.status() != WL_CONNECTED) {
    static uint32_t lastWifiTry = 0;
    if (millis() - lastWifiTry > 5000) {
      lastWifiTry = millis();
      ensureWifi();
    }
    return;
  }

  serveTcp();

  if (!bmsConnected) {
    uint32_t now = millis();
    if (now - lastBleAttempt >= bleBackoffMs) {
      lastBleAttempt = now;
      if (!connectToBms()) {
        if (scanCB.targetFound) {
          bleBackoffMs = 5000;
          Serial.println("[BLE] Retrying in 5s...");
        } else {
          bleBackoffMs += 10000;
          if (bleBackoffMs > 60000) bleBackoffMs = 60000;
          Serial.printf("[BLE] Retrying in %lus...\n",
                        (unsigned long)(bleBackoffMs / 1000));
        }
      }
    }
    return;
  }

  if (pBLEClient && !pBLEClient->isConnected()) {
    bmsConnected = false;
    return;
  }
}
