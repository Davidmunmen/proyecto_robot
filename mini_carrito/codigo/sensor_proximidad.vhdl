-- Módulo: Sensor de Proximidad
-- Descripción: Interfaz para leer el sensor de proximidad HC-SR04
-- Autor: Proyecto Robot
-- Fecha: 2026

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sensor_proximidad is
    generic (
        CLK_FREQ : integer := 50_000_000  -- Frecuencia del reloj en Hz (50 MHz)
    );
    port (
        clk         : in  std_logic;
        reset       : in  std_logic;
        trig        : out std_logic;           -- Pulso de trigger
        echo        : in  std_logic;           -- Pulso de echo
        distancia   : out std_logic_vector(15 downto 0);  -- Distancia en cm
        dato_valido : out std_logic            -- Indica que la medida es válida
    );
end entity sensor_proximidad;

architecture rtl of sensor_proximidad is
    constant TRIG_DURACION : integer := 500;  -- Duración del trigger en ciclos (10 us)
    constant PRESCALER     : integer := 50;   -- Para obtener 1 us por ciclo
    
    signal contador_trig   : integer range 0 to 100_000 := 0;
    signal contador_echo   : integer range 0 to 2_000_000 := 0;
    signal echo_anterior   : std_logic := '0';
    signal echo_activo     : std_logic := '0';
    signal frecuencia_1us  : integer := 0;
    
begin
    
    process(clk, reset)
    begin
        if reset = '1' then
            trig <= '0';
            contador_trig <= 0;
            dado_valido <= '0';
            distancia <= (others => '0');
            echo_anterior <= '0';
            echo_activo <= '0';
            contador_echo <= 0;
            frecuencia_1us <= 0;
            
        elsif rising_edge(clk) then
            -- Generador de pulso de trigger (10 us cada 100 us)
            if contador_trig < TRIG_DURACION then
                trig <= '1';
            elsif contador_trig < 5000 then
                trig <= '0';
            else
                contador_trig <= 0;
            end if;
            
            if contador_trig < 5000 then
                contador_trig <= contador_trig + 1;
            end if;
            
            -- Contador para generar pulso de 1 us
            if frecuencia_1us < PRESCALER - 1 then
                frecuencia_1us <= frecuencia_1us + 1;
            else
                frecuencia_1us <= 0;
            end if;
            
            -- Detección de flanco de echo
            echo_anterior <= echo;
            if echo_anterior = '0' and echo = '1' then
                echo_activo <= '1';
                contador_echo <= 0;
            elsif echo = '0' and echo_activo = '1' then
                echo_activo <= '0';
                -- Convertir el tiempo en distancia (tiempo / 58 = cm)
                distancia <= std_logic_vector(to_unsigned(contador_echo / 58, 16));
                dato_valido <= '1';
            elsif echo_activo = '1' and frecuencia_1us = 0 then
                contador_echo <= contador_echo + 1;
            end if;
            
        end if;
    end process;
    
end architecture rtl;
