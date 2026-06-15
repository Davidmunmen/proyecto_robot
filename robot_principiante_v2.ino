// ============================================================
// ROBOT ESQUIVA OBSTÁCULOS - VERSIÓN PRINCIPIANTE
// ============================================================
// Este código es SIMPLE para que entiendas cómo funciona
// Después agregaremos Bluetooth

// ===== DEFINIR PINES =====
// Sensor ultrasónico
int trigPin = 3;   // Pin que ENVÍA la señal
int echoPin = 2;   // Pin que RECIBE la señal

// Motores
int Motor1_Adelante = 13;   // Motor izquierdo ADELANTE
int Motor1_Atras = 12;      // Motor izquierdo ATRÁS
int Motor2_Adelante = 8;    // Motor derecho ADELANTE
int Motor2_Atras = 10;      // Motor derecho ATRÁS

// Velocidad PWM
int VelocidadMotor1 = 5;    // Velocidad motor izquierdo
int VelocidadMotor2 = 6;    // Velocidad motor derecho

// ===== VARIABLES GLOBALES =====
long duracion;              // Tiempo que tarda el sonido
int distancia;              // Distancia en centímetros

// Velocidades (ajusta estos valores si el robot va muy rápido o lento)
int velNormal = 210;        // Velocidad normal (0-255)
int velGiro = 180;          // Velocidad al girar (0-255)
int velGiroLento = 150;     // Velocidad del motor lento al girar (0-255)

// ============================================================
// SETUP - Se ejecuta UNA SOLA VEZ cuando enciendes Arduino
// ============================================================
void setup() {
  // Abrir comunicación serial (para ver mensajes en PC)
  Serial.begin(9600);
  Serial.println(""); 
  Serial.println("=========================================");
  Serial.println("ROBOT ESQUIVA OBSTÁCULOS - INICIADO");
  Serial.println("=========================================");
  Serial.println("");
  
  // Configurar pines del sensor ultrasónico
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
  
  // Configurar pines de los motores
  pinMode(Motor1_Adelante, OUTPUT);
  pinMode(Motor1_Atras, OUTPUT);
  pinMode(Motor2_Adelante, OUTPUT);
  pinMode(Motor2_Atras, OUTPUT);
  pinMode(VelocidadMotor1, OUTPUT);
  pinMode(VelocidadMotor2, OUTPUT);
  
  // Establecer velocidad inicial
  analogWrite(VelocidadMotor1, velNormal);
  analogWrite(VelocidadMotor2, velNormal);
  
  Serial.println("Pines configurados correctamente");
  Serial.println("Esperando comando...");
  Serial.println("");
  
  delay(1000);
}

// ============================================================
// LOOP - Se ejecuta infinitamente (mientras el Arduino está encendido)
// ============================================================
void loop() {
  // Medir distancia
  distancia = medirDistancia();
  
  // Mostrar en Serial Monitor
  Serial.print("Distancia: ");
  Serial.print(distancia);
  Serial.println(" cm");
  
  // LÓGICA:
  // Si hay obstáculo muy cerca (<10cm) → RETROCEDER y girar
  // Si hay obstáculo cerca (<20cm) → PARAR y girar
  // Si el camino está libre → ADELANTE
  
  if (distancia < 10) {
    Serial.println(">>> MUY CERCA - RETROCEDIENDO");
    pararRobot();
    delay(200);
    retrocederRobot();
    delay(500);
    pararRobot();
    delay(200);
    girarDerechaRobot();
    delay(600);
  }
  else if (distancia < 20) {
    Serial.println(">>> OBSTÁCULO DETECTADO - GIRANDO");
    pararRobot();
    delay(300);
    girarDerechaRobot();
    delay(600);
  } 
  else {
    Serial.println(">>> Camino libre - ADELANTE");
    adelanteRobot();
  }
  
  delay(100);
}

// ============================================================
// FUNCIÓN: MEDIR DISTANCIA CON SENSOR ULTRASÓNICO
// ============================================================
int medirDistancia() {
  // PASO 1: Enviar pulso
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);
  
  // PASO 2: Recibir echo
  duracion = pulseIn(echoPin, HIGH, 30000);
  
  // PASO 3: Convertir a distancia
  distancia = (duracion * 0.034) / 2;
  
  // Limitar valores raros
  if (distancia > 200 || distancia < 2) {
    distancia = 200;
  }
  
  return distancia;
}

// ============================================================
// FUNCIONES DE MOVIMIENTO
// ============================================================

// ADELANTE - Ambos motores hacia adelante
void adelanteRobot() {
  // Motor 1: Adelante
  digitalWrite(Motor1_Adelante, HIGH);
  digitalWrite(Motor1_Atras, LOW);
  
  // Motor 2: Adelante
  digitalWrite(Motor2_Adelante, HIGH);
  digitalWrite(Motor2_Atras, LOW);
  
  // Velocidad normal
  analogWrite(VelocidadMotor1, velNormal);
  analogWrite(VelocidadMotor2, velNormal);
}

// PARAR - Todos los motores apagados
void pararRobot() {
  digitalWrite(Motor1_Adelante, LOW);
  digitalWrite(Motor1_Atras, LOW);
  digitalWrite(Motor2_Adelante, LOW);
  digitalWrite(Motor2_Atras, LOW);
}

// RETROCEDER - Ambos motores hacia atrás
void retrocederRobot() {
  // Motor 1: Atrás
  digitalWrite(Motor1_Adelante, LOW);
  digitalWrite(Motor1_Atras, HIGH);
  
  // Motor 2: Atrás
  digitalWrite(Motor2_Adelante, LOW);
  digitalWrite(Motor2_Atras, HIGH);
  
  // Velocidad media
  analogWrite(VelocidadMotor1, velGiro);
  analogWrite(VelocidadMotor2, velGiro);
}

// GIRAR DERECHA - Motor1 atrás, Motor2 adelante
void girarDerechaRobot() {
  // Motor 1: Atrás (gira hacia la derecha)
  digitalWrite(Motor1_Adelante, LOW);
  digitalWrite(Motor1_Atras, HIGH);
  analogWrite(VelocidadMotor1, velGiroLento);
  
  // Motor 2: Adelante
  digitalWrite(Motor2_Adelante, HIGH);
  digitalWrite(Motor2_Atras, LOW);
  analogWrite(VelocidadMotor2, velGiro);
}

// GIRAR IZQUIERDA - Motor1 adelante, Motor2 atrás
void girarIzquierdaRobot() {
  // Motor 1: Adelante
  digitalWrite(Motor1_Adelante, HIGH);
  digitalWrite(Motor1_Atras, LOW);
  analogWrite(VelocidadMotor1, velGiro);
  
  // Motor 2: Atrás (gira hacia la izquierda)
  digitalWrite(Motor2_Adelante, LOW);
  digitalWrite(Motor2_Atras, HIGH);
  analogWrite(VelocidadMotor2, velGiroLento);
}

// ============================================================
// FIN DEL CÓDIGO
// ============================================================
