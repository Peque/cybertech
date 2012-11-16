EESchema Schematic File Version 2  date Fri 16 Nov 2012 01:27:02 PM CET
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
LIBS:reset
LIBS:heracles-cache
EELAYER 25  0
EELAYER END
$Descr A4 11700 8267
encoding utf-8
Sheet 4 5
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
	4100 3850 4700 3850
Wire Wire Line
	9000 3750 9400 3750
Wire Wire Line
	8450 3750 8600 3750
Wire Wire Line
	7950 4100 7350 4100
Wire Wire Line
	7350 4100 7350 3050
Wire Wire Line
	7350 3050 6600 3050
Wire Wire Line
	1500 3750 2050 3750
Wire Wire Line
	7550 4900 4550 4900
Connection ~ 6000 4900
Wire Wire Line
	6000 4600 6000 4900
Wire Wire Line
	7950 3750 6600 3750
Wire Wire Line
	8450 4100 8600 4100
Wire Wire Line
	8450 3050 9100 3050
Connection ~ 7750 2750
Wire Wire Line
	8500 2750 9100 2750
Wire Wire Line
	4300 2850 4700 2850
Wire Wire Line
	4700 2750 4300 2750
Wire Wire Line
	6600 3550 7100 3550
Wire Wire Line
	7100 3550 7100 2750
Connection ~ 7100 2750
Wire Wire Line
	6600 2750 7900 2750
Wire Wire Line
	7750 2750 7750 3050
Wire Wire Line
	7750 3050 7950 3050
Wire Wire Line
	9000 4100 9400 4100
Wire Wire Line
	4700 3950 4550 3950
Wire Wire Line
	4550 3950 4550 4900
Wire Wire Line
	6600 3950 6750 3950
Wire Wire Line
	6750 3950 6750 4900
Connection ~ 6750 4900
Wire Wire Line
	1500 3550 2050 3550
Wire Wire Line
	6600 2950 7600 2950
Wire Wire Line
	7600 2950 7600 3750
Connection ~ 7600 3750
Wire Wire Line
	3700 3850 2950 3850
$Comp
L GS2 GS?
U 1 1 50A31F90
P 3900 3850
F 0 "GS?" H 4000 4000 50  0000 C CNN
F 1 "GS2" H 4000 3701 40  0000 C CNN
	1    3900 3850
	0    -1   -1   0   
$EndComp
Text HLabel 4300 2850 0    60   Input ~ 0
UART_RXD
Text HLabel 4300 2750 0    60   Output ~ 0
UART_TXD
$Comp
L R R?
U 1 1 509BCECF
P 8200 3750
F 0 "R?" V 8280 3750 50  0000 C CNN
F 1 "470" V 8200 3750 50  0000 C CNN
	1    8200 3750
	0    -1   -1   0   
$EndComp
$Comp
L LED D?
U 1 1 509BCECE
P 8800 3750
F 0 "D?" H 8800 3850 50  0000 C CNN
F 1 "Pairing LED" H 8800 3650 50  0000 C CNN
	1    8800 3750
	1    0    0    -1  
$EndComp
Text Label 9400 3750 2    60   ~ 0
GND
Text Label 2950 3850 0    60   ~ 0
3V3
Text Label 2050 3750 2    60   ~ 0
GND
Text Label 2050 3550 2    60   ~ 0
3V3
Text GLabel 1500 3750 0    60   Input ~ 0
GND
Text GLabel 1500 3550 0    60   Input ~ 0
3V3
Text Label 7550 4900 2    60   ~ 0
GND
Text Label 9400 4100 2    60   ~ 0
GND
$Comp
L LED D?
U 1 1 509BCB23
P 8800 4100
F 0 "D?" H 8800 4200 50  0000 C CNN
F 1 "Work mode LED" H 8800 4000 50  0000 C CNN
	1    8800 4100
	1    0    0    -1  
$EndComp
$Comp
L R R?
U 1 1 509BCB0A
P 8200 4100
F 0 "R?" V 8280 4100 50  0000 C CNN
F 1 "470" V 8200 4100 50  0000 C CNN
	1    8200 4100
	0    -1   -1   0   
$EndComp
Text Label 9100 3050 2    60   ~ 0
GND
Text Label 9100 2750 2    60   ~ 0
3V3
$Comp
L R R?
U 1 1 509BCA51
P 8200 3050
F 0 "R?" V 8280 3050 50  0000 C CNN
F 1 "10K" V 8200 3050 50  0000 C CNN
	1    8200 3050
	0    -1   -1   0   
$EndComp
$Comp
L SW_PUSH SW?
U 1 1 509BCA1B
P 8200 2750
F 0 "SW?" H 8350 2860 50  0000 C CNN
F 1 "SW_PUSH" H 8200 2670 50  0000 C CNN
	1    8200 2750
	1    0    0    -1  
$EndComp
NoConn ~ 6600 2850
NoConn ~ 6600 3150
NoConn ~ 6600 3250
NoConn ~ 6600 3350
NoConn ~ 6600 3450
NoConn ~ 6600 3650
NoConn ~ 6600 3850
NoConn ~ 4700 3150
NoConn ~ 4700 3050
NoConn ~ 4700 2950
NoConn ~ 5900 4600
NoConn ~ 5800 4600
NoConn ~ 5700 4600
NoConn ~ 5600 4600
NoConn ~ 5500 4600
NoConn ~ 5400 4600
NoConn ~ 5300 4600
NoConn ~ 4700 3750
NoConn ~ 4700 3650
NoConn ~ 4700 3550
NoConn ~ 4700 3450
NoConn ~ 4700 3350
NoConn ~ 4700 3250
$Comp
L HC-0X U?
U 1 1 509BC507
P 5650 3250
F 0 "U?" H 5050 3950 60  0000 C CNN
F 1 "HC-0X" H 6150 3950 60  0000 C CNN
	1    5650 3250
	1    0    0    -1  
$EndComp
$EndSCHEMATC
