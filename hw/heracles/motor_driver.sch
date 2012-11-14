EESchema Schematic File Version 2  date Wed 14 Nov 2012 05:29:47 AM CET
LIBS:power
LIBS:device
LIBS:transistors
LIBS:conn
LIBS:linear
LIBS:regul
LIBS:74xx
LIBS:cmos4000
LIBS:adc-dac
LIBS:memory
LIBS:xilinx
LIBS:special
LIBS:microcontrollers
LIBS:dsp
LIBS:microchip
LIBS:analog_switches
LIBS:motorola
LIBS:texas
LIBS:intel
LIBS:audio
LIBS:interface
LIBS:digital-audio
LIBS:philips
LIBS:display
LIBS:cypress
LIBS:siliconi
LIBS:opto
LIBS:atmel
LIBS:contrib
LIBS:valves
LIBS:motor_drivers
LIBS:bluetooth
LIBS:power_converter
LIBS:reflective_sensor
LIBS:74
LIBS:microcontroller
LIBS:heracles-cache
EELAYER 25  0
EELAYER END
$Descr A4 11700 8267
encoding utf-8
Sheet 4 4
Title ""
Date "14 nov 2012"
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Wire Wire Line
	4450 3600 4450 3700
Wire Wire Line
	5000 4050 5000 3950
Wire Wire Line
	5000 3950 4050 3950
Wire Wire Line
	4050 3100 4450 3100
Connection ~ 4450 4550
Wire Wire Line
	4450 3950 4450 4050
Wire Wire Line
	8850 4850 8450 4850
Wire Wire Line
	8850 4450 8450 4450
Wire Wire Line
	6950 5450 7400 5450
Wire Wire Line
	6950 5050 7400 5050
Wire Wire Line
	6950 4650 7400 4650
Wire Wire Line
	8650 3550 9000 3550
Wire Wire Line
	8650 3350 9000 3350
Wire Wire Line
	8650 3150 9000 3150
Wire Wire Line
	8650 2950 9000 2950
Wire Wire Line
	8650 2750 9000 2750
Wire Wire Line
	8650 2550 9000 2550
Wire Wire Line
	7050 3550 6700 3550
Wire Wire Line
	7050 3350 6700 3350
Wire Wire Line
	7050 3150 6700 3150
Wire Wire Line
	6700 2950 7050 2950
Wire Wire Line
	7050 2450 6700 2450
Wire Wire Line
	7050 2750 6700 2750
Wire Wire Line
	2150 4200 2600 4200
Wire Wire Line
	2150 3800 2600 3800
Wire Wire Line
	2150 4000 2600 4000
Wire Wire Line
	7050 2650 6700 2650
Wire Wire Line
	7050 2550 6700 2550
Wire Wire Line
	6700 2850 7050 2850
Wire Wire Line
	7050 3050 6700 3050
Wire Wire Line
	7050 3250 6700 3250
Wire Wire Line
	7050 3450 6700 3450
Wire Wire Line
	8650 2450 9000 2450
Wire Wire Line
	8650 2650 9000 2650
Wire Wire Line
	8650 2850 9000 2850
Wire Wire Line
	8650 3050 9000 3050
Wire Wire Line
	8650 3250 9000 3250
Wire Wire Line
	8650 3450 9000 3450
Wire Wire Line
	6950 4450 7400 4450
Wire Wire Line
	6950 4850 7400 4850
Wire Wire Line
	6950 5250 7400 5250
Wire Wire Line
	6950 5650 7400 5650
Wire Wire Line
	8850 4650 8450 4650
Wire Wire Line
	8850 5050 8450 5050
Wire Wire Line
	4450 4550 4450 4450
Connection ~ 4450 3950
Wire Wire Line
	4450 3700 4050 3700
Wire Wire Line
	4050 4550 5000 4550
Wire Wire Line
	5000 4550 5000 4450
Wire Wire Line
	4450 3100 4450 3200
Text Label 4050 3100 0    60   ~ 0
3V3
Text Label 4050 3950 0    60   ~ 0
VMOT
Text Label 4050 3700 0    60   ~ 0
GND
Text Label 4050 4550 0    60   ~ 0
GND
$Comp
L CP1 C?
U 1 1 509B13AD
P 5000 4250
F 0 "C?" H 5050 4350 50  0000 L CNN
F 1 "10uF , 20V" H 5050 4150 50  0000 L CNN
	1    5000 4250
	1    0    0    -1  
$EndComp
$Comp
L C C?
U 1 1 509B139B
P 4450 4250
F 0 "C?" H 4500 4350 50  0000 L CNN
F 1 "0.1uF" H 4500 4150 50  0000 L CNN
	1    4450 4250
	1    0    0    -1  
$EndComp
$Comp
L C C?
U 1 1 509B1393
P 4450 3400
F 0 "C?" H 4500 3500 50  0000 L CNN
F 1 "0.1uF" H 4500 3300 50  0000 L CNN
	1    4450 3400
	1    0    0    -1  
$EndComp
Text Label 6700 3150 0    60   ~ 0
BO2
Text Label 6700 3050 0    60   ~ 0
BO2
Text Label 6700 3550 0    60   ~ 0
BO1
Text Label 6700 3450 0    60   ~ 0
BO1
Text Label 6700 2950 0    60   ~ 0
AO2
Text Label 6700 2850 0    60   ~ 0
AO2
Text Label 6700 2550 0    60   ~ 0
AO1
Text Label 6700 2450 0    60   ~ 0
AO1
Text Label 8450 5050 0    60   ~ 0
BO2
Text Label 8450 4850 0    60   ~ 0
BO1
Text Label 8450 4650 0    60   ~ 0
AO2
Text Label 8450 4450 0    60   ~ 0
AO1
Text Label 9000 2850 2    60   ~ 0
3V3
Text Label 9000 2450 2    60   ~ 0
VMOT
Text Label 9000 3450 2    60   ~ 0
VMOT
Text Label 9000 3550 2    60   ~ 0
VMOT
Text HLabel 8850 5050 2    60   Output ~ 0
BO2
Text HLabel 8850 4850 2    60   Output ~ 0
BO1
Text HLabel 8850 4650 2    60   Output ~ 0
AO2
Text HLabel 8850 4450 2    60   Output ~ 0
AO1
Text Label 9000 2950 2    60   ~ 0
STBY
Text Label 9000 3350 2    60   ~ 0
PWMB
Text Label 9000 3250 2    60   ~ 0
BIN2
Text Label 9000 3150 2    60   ~ 0
BIN1
Text Label 9000 2550 2    60   ~ 0
PWMA
Text Label 9000 2650 2    60   ~ 0
AIN2
Text Label 9000 2750 2    60   ~ 0
AIN1
Text Label 7400 5650 2    60   ~ 0
STBY
Text Label 7400 5450 2    60   ~ 0
PWMB
Text Label 7400 5250 2    60   ~ 0
BIN2
Text Label 7400 5050 2    60   ~ 0
BIN1
Text Label 7400 4850 2    60   ~ 0
PWMA
Text Label 7400 4650 2    60   ~ 0
AIN2
Text Label 7400 4450 2    60   ~ 0
AIN1
Text HLabel 6950 5650 0    60   Input ~ 0
STBY
Text HLabel 6950 4450 0    60   Input ~ 0
AIN1
Text HLabel 6950 4650 0    60   Input ~ 0
AIN2
Text HLabel 6950 4850 0    60   Input ~ 0
PWMA
Text HLabel 6950 5450 0    60   Input ~ 0
PWMB
Text HLabel 6950 5250 0    60   Input ~ 0
BIN2
Text HLabel 6950 5050 0    60   Input ~ 0
BIN1
Text Label 6700 2650 0    60   ~ 0
GND
Text Label 6700 2750 0    60   ~ 0
GND
Text Label 6700 3250 0    60   ~ 0
GND
Text Label 6700 3350 0    60   ~ 0
GND
Text Label 9000 3050 2    60   ~ 0
GND
Text Label 2600 4200 2    60   ~ 0
GND
Text Label 2600 4000 2    60   ~ 0
3V3
Text Label 2600 3800 2    60   ~ 0
VMOT
Text GLabel 2150 3800 0    60   UnSpc ~ 0
VMOT
Text GLabel 2150 4000 0    60   UnSpc ~ 0
3V3
Text GLabel 2150 4200 0    60   UnSpc ~ 0
GND
$Comp
L TB6621FNG U?
U 1 1 509B0C77
P 7850 3000
F 0 "U?" H 7400 3800 50  0000 C CNN
F 1 "TB6621FNG" H 7550 2200 50  0000 C CNN
F 2 "SSOP24" H 7850 3000 50  0001 C CNN
	1    7850 3000
	1    0    0    -1  
$EndComp
$EndSCHEMATC
