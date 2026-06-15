// ============================================================
// ROBOT ESQUIVA OBSTÁCULOS - CON FPGA DE10-LITE
// ============================================================
// Arduino lee sensores y envía datos a la FPGA
// FPGA decide qué hacer y envía comandos de vuelta
// Arduino ejecuta los comandos (mueve motores)

#include <SoftwareSerial.h>

// ===== COMUNICACIÓN CON FPGA =====
// Pin 4 = TX (envía a FPGA)
// Pin 7 = RX (recibe de FPGA)
SoftwareSerial fpgaSerial(7, 4);  // RX, TX

// ===== DEFINIR PINES =====
// Sensor ultrasónico
int trigPin = 3;
int echoPin = 2;

// Motores
int Motor1_Adelante = 13;
int Motor1_Atras = 12;
int Motor2_Adelante = 8;
int Motor2_Atras = 10;

// Velocidad PWM
int VelocidadMotor1 = 5;
int VelocidadMotor2 = 6;

// ===== VARIABLES =====
long duracion;
int distancia;
int velNormal = 255;
int velGiro = 230;
int velGiroLento = 200;

// ============================================================
// SETUP
// ============================================================
void setup() {
  // Serial para debug en PC
  Serial.begin(9600);
  Serial.println("=========================================");
  Serial.println("ROBOT + FPGA - INICIADO");
  Serial.println("=========================================");
  
  // Serial para FPGA (9600 baud)
  fpgaSerial.begin(9600);
  
  // Sensor ultrasónico
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
  
  // Motores
  pinMode(Motor1_Adelante, OUTPUT);
  pinMode(Motor1_Atras, OUTPUT);
  pinMode(Motor2_Adelante, OUTPUT);
  pinMode(Motor2_Atras, OUTPUT);
  pinMode(VelocidadMotor1, OUTPUT);
  pinMode(VelocidadMotor2, OUTPUT);
  
  analogWrite(VelocidadMotor1, velNormal);
  analogWrite(VelocidadMotor2, velNormal);
  
  delay(1000);
}

// ============================================================
// LOOP PRINCIPAL
// ============================================================
void loop() {
  // 1. Medir distancia
  distancia = medirDistancia();
  
  // 2. Enviar distancia a la FPGA como un byte (0-200)
  if (distancia > 200) distancia = 200;
  fpgaSerial.write((byte)distancia);
  
  // 3. Debug en PC
  Serial.print("Dist: ");
  Serial.print(distancia);
  Serial.print(" cm");
  
  // 4. Recibir comando de la FPGA
  if (fpgaSerial.available()) {
    char comando = fpgaSerial.read();
    Serial.print(" | FPGA dice: ");
    Serial.println(comando);
    
    // 5. Ejecutar comando
    ejecutarComando(comando);
  } else {
    Serial.println(" | Esperando FPGA...");
    // Si no hay FPGA, ejecutar lógica local como respaldo
    if (distancia < 20) {
      pararRobot();
      delay(300);
      girarDerechaRobot();
      delay(600);
    } else {
      adelanteRobot();
    }
  }
  
  delay(100);
}

// ============================================================
// EJECUTAR COMANDO DE LA FPGA
// ============================================================
void ejecutarComando(char cmd) {
  switch(cmd) {
    case 'F':  // Forward - Adelante
      Serial.println(">>> CMD: ADELANTE");
      adelanteRobot();
      break;
      
    case 'R':  // Right - Derecha
      Serial.println(">>> CMD: GIRAR DERECHA");
      girarDerechaRobot();
      delay(500);
      break;
      
    case 'L':  // Left - Izquierda
      Serial.println(">>> CMD: GIRAR IZQUIERDA");
      girarIzquierdaRobot();
      delay(500);
      break;
      
    case 'S':  // Stop - Parar
      Serial.println(">>> CMD: PARAR");
      pararRobot();
      break;
      
    case 'B':  // Back - Retroceder
      Serial.println(">>> CMD: RETROCEDER");
      retrocederRobot();
      delay(500);
      break;
      
    case 'E':  // Escape - Maniobra de escape (atascado)
      Serial.println(">>> CMD: ESCAPE");
      retrocederRobot();
      delay(800);
      pararRobot();
      delay(200);
      girarDerechaRobot();
      delay(1000);
      break;
      
    default:
      break;
  }
}

// ============================================================
// FUNCIONES DE MOVIMIENTO
// ============================================================
void adelanteRobot() {
  digitalWrite(Motor1_Adelante, HIGH);
  digitalWrite(Motor1_Atras, LOW);
  digitalWrite(Motor2_Adelante, HIGH);
  digitalWrite(Motor2_Atras, LOW);
  analogWrite(VelocidadMotor1, velNormal);
  analogWrite(VelocidadMotor2, velNormal);
}

void pararRobot() {
  digitalWrite(Motor1_Adelante, LOW);
  digitalWrite(Motor1_Atras, LOW);
  digitalWrite(Motor2_Adelante, LOW);
  digitalWrite(Motor2_Atras, LOW);
}

void retrocederRobot() {
  digitalWrite(Motor1_Adelante, LOW);
  digitalWrite(Motor1_Atras, HIGH);
  digitalWrite(Motor2_Adelante, LOW);
  digitalWrite(Motor2_Atras, HIGH);
  analogWrite(VelocidadMotor1, velGiro);
  analogWrite(VelocidadMotor2, velGiro);
}

void girarDerechaRobot() {
  digitalWrite(Motor1_Adelante, LOW);
  digitalWrite(Motor1_Atras, HIGH);
  analogWrite(VelocidadMotor1, velGiroLento);
  digitalWrite(Motor2_Adelante, HIGH);
  digitalWrite(Motor2_Atras, LOW);
  analogWrite(VelocidadMotor2, velGiro);
}

void girarIzquierdaRobot() {
  digitalWrite(Motor1_Adelante, HIGH);
  digitalWrite(Motor1_Atras, LOW);
  analogWrite(VelocidadMotor1, velGiro);
  digitalWrite(Motor2_Adelante, LOW);
  digitalWrite(Motor2_Atras, HIGH);
  analogWrite(VelocidadMotor2, velGiroLento);
}

// ============================================================
// SENSOR ULTRASÓNICO
// ============================================================
int medirDistancia() {
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);
  
  duracion = pulseIn(echoPin, HIGH, 30000);
  distancia = (duracion * 0.034) / 2;
  
  if (distancia > 200 || distancia < 2) {
    distancia = 200;
  }
  return distancia;
}
