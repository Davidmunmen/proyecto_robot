Proyecto Final: Diseño Digital VLSI

Este proyecto consiste en el diseño e implementación de un sistema robótico autónomo basado en una FPGA 10 (DE10-Lite). El robot es capaz de localizar una fuente luminosa y navegar hacia ella evitando obstáculos en tiempo real mediante una arquitectura de control distribuida.

Descripción del Proyecto
El sistema utiliza una Máquina de Estados Finitos (FSM) implementada en VHDL/Verilog dentro de la FPGA para la toma de decisiones lógica. La FPGA se comunica con un Arduino que actúa como puente para gestionar la lectura de sensores analógicos/ultrasónicos y el control de los motores.
Características Principales

    Control de Motores: 2 motores DC con PWM de 8 bits (>18 kHz).

    Sensado: 4 sensores LDR para dirección de luz y 4 sensores ultrasónicos para proximidad.

    Lógica de Control: FSM con estados de Búsqueda, Seguimiento, Esquiva, Giro y Meta.

    Seguridad: Algoritmo de detección de atasco (escape maneuver).

    Interfaz: Visualización de estados y Duty Cycle en los displays de 7 segmentos de la DE10-Lite.

Arquitectura del Sistema
Hardware

    FPGA Altera DE10-Lite: Núcleo de procesamiento lógico y FSM.

    Arduino (Uno/Mega): Interface de sensores y driver.

    Sensores: 4x LDR con comparadores LM339, 4x HC-SR04.

    Actuadores: Puente H L293D/L298N y motores DC.

Conexión FPGA y Arduino

La comunicación se establece mediante un bus paralelo de señales lógicas:

    FPGA → Arduino: Señales de dirección (In1, In2, In3, In4) y señales PWM generadas en la FPGA.

    Arduino → FPGA: Flags de detección (Luz detectada, Obstáculo cerca, Atasco).
