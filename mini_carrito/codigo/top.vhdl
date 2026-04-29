-- Módulo: Top Level - Mini Carrito con Sensor de Proximidad
-- Descripción: Entidad top que integra sensor, control y motores
-- Autor: Proyecto Robot
-- Fecha: 2026

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
    port (
        clk             : in  std_logic;
        reset           : in  std_logic;
        
        -- Sensor de Proximidad HC-SR04
        sensor_trig     : out std_logic;
        sensor_echo     : in  std_logic;
        
        -- Motor Izquierdo
        motor_izq_fwd   : out std_logic;
        motor_izq_bwd   : out std_logic;
        motor_izq_pwm   : out std_logic;
        
        -- Motor Derecho
        motor_der_fwd   : out std_logic;
        motor_der_bwd   : out std_logic;
        motor_der_pwm   : out std_logic;
        
        -- Salidas de debug
        led_alerta      : out std_logic;
        estado_debug    : out std_logic_vector(2 downto 0)
    );
end entity top;

architecture structural of top is
    
    -- Señales internas
    signal distancia       : std_logic_vector(15 downto 0);
    signal dato_valido     : std_logic;
    signal velocidad_izq   : std_logic_vector(7 downto 0);
    signal velocidad_der   : std_logic_vector(7 downto 0);
    signal direccion       : std_logic_vector(2 downto 0);
    signal estado          : std_logic_vector(2 downto 0);
    
begin
    
    -- Instancia del módulo sensor de proximidad
    sensor_inst : entity work.sensor_proximidad
        generic map (
            CLK_FREQ => 50_000_000
        )
        port map (
            clk         => clk,
            reset       => reset,
            trig        => sensor_trig,
            echo        => sensor_echo,
            distancia   => distancia,
            dato_valido => dato_valido
        );
    
    -- Instancia del módulo de control del carrito
    control_inst : entity work.control_carrito
        generic map (
            CLK_FREQ   => 50_000_000,
            DIST_MIN   => 20,
            DIST_ALERTA => 30
        )
        port map (
            clk         => clk,
            reset       => reset,
            distancia   => distancia,
            dato_valido => dato_valido,
            velocidad_izq => velocidad_izq,
            velocidad_der => velocidad_der,
            direccion   => direccion,
            estado      => estado,
            led_alerta  => led_alerta
        );
    
    -- Instancia del módulo de control de motores
    motor_inst : entity work.motor_control
        generic map (
            CLK_FREQ => 50_000_000,
            PWM_FREQ => 1000
        )
        port map (
            clk         => clk,
            reset       => reset,
            motor_izq_fwd => motor_izq_fwd,
            motor_izq_bwd => motor_izq_bwd,
            motor_izq_pwm => motor_izq_pwm,
            motor_der_fwd => motor_der_fwd,
            motor_der_bwd => motor_der_bwd,
            motor_der_pwm => motor_der_pwm,
            velocidad_izq => velocidad_izq,
            velocidad_der => velocidad_der,
            direccion   => direccion
        );
    
    -- Asignación de salidas debug
    estado_debug <= estado;
    
end architecture structural;
