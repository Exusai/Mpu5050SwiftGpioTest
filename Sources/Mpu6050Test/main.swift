/// PINS
/*
        3v    (1)(2) 5v
SDA --- 2 SDA (3)(4) 5v  --- VCC
SCL --- 3 SCL (5)(6) GND --- GND
              (7)(8) 14 txd --- NA
*/
//Imports
import SwiftyGPIO
//import MPU6050
import Foundation

//Init the MPU6050 and HW
let i2cs = SwiftyGPIO.hardwareI2Cs(for:.RaspberryPi3)!
let i2c = i2cs[1]

let mp = MPU6050(i2c)
//mp.reset()
mp.enable(true)
mp.range(gyroRange: 1, accelRange: 2) // Define los rangos de operación del sensor

//Actual code
var gyroX: Int = 0
var gyroY: Int = 0
var gyroZ: Int = 0

var gxCal: Int = 0
var gyCal: Int = 0
var gzCal: Int = 0

var axCal: Int = 0
var ayCal: Int = 0
var azCal: Int = 0

var Vx: Double = 0
var Vy: Double = 0
var Vz: Double = 0

var x: Double = 0
var y: Double = 0
var z: Double = 0

var pitchAngle: Double = 0.0
var rollAngle: Double = 0.0
var yawAngle: Double = 0.0

var rollAngleAccel: Double = 0.0
var pitchAngleAccel: Double = 0.0
var yawAngleAccel: Double = 0.0

var accelVectorMag: Float = 0

var pitchOut: Double = 0
var rollOut: Double = 0
var yawOut: Double = 0

var setGyroAngles: Bool = false

/// CALIBRATING
print("Calibrando")
for n in 0...500 {
	if n % 125 == 0 {
        print(".", terminator: " ")
	}
	let (ax,ay,az,_,gx,gy,gz) = mp.getAll()
	gxCal += gx
	gyCal += gy
	gzCal += gz
    
    axCal += ax
    ayCal += ay
    azCal += az
	//usleep(200)
}

gxCal = gxCal / 500
gyCal = gyCal / 500
gzCal = gzCal / 500

axCal = gxCal / 500
ayCal = gyCal / 500
azCal = gzCal / 500
print("\n")
print("gxProm: \(gxCal) gyProm: \(gyCal) gzProm: \(gzCal) ")
print("axProm: \(axCal) ayProm: \(ayCal) azProm: \(azCal) ")
print("Calibrado")

// Inicializar tiempo.
let ferventTempo = FerventTempo()
let positionTempo = FerventTempo()

// Headers
print("Pitch\tRoll\tYaw\tX\tY\tZ\tTemp")
while(true){
	let (ax, ay, az, t, gx, gy, gz) = mp.getAll()
	gyroX = gx - gxCal
	gyroY = gy - gyCal
	gyroZ = gz - gzCal
	
    //let refreshRate = 1 / ferventTempo.Delta
    let vx = Double(gyroX) / 65.5
    let vy = Double(gyroY) / 65.5
    let vz = Double(gyroZ) / 65.5 // 7.88 Debe haber un error, debería ser 65.5 y 7.88 ni esta en la datasheet
    let delta = ferventTempo.Delta
    
    // Gyro ang calc
    pitchAngle += vx * delta
    rollAngle += vy * delta
    yawAngle += vz * delta

	// Transferencia de ang
	let deg2rad: Double  = (Double.pi / 180)
	pitchAngle += rollAngle * sin(Double(yawAngle) * deg2rad)
	rollAngle -= pitchAngle * sin(Double(yawAngle) * deg2rad)

	// Accel ang calc
	let ax2: Float = Float(ax) * Float(ax)
	let ay2: Float = Float(ay) * Float(ay)
	let az2: Float = Float(az) * Float(az)
	accelVectorMag = Float(sqrt(ax2 + ay2 + az2))
	pitchAngleAccel = asin(Double(Float(ay)/accelVectorMag)) * 57.29 // 57.29 = rad2deg
	rollAngleAccel = asin(Double(Float(ax)/accelVectorMag)) * -57.29 // 57.29 = rad2deg

	// Calibrate Accel angles
	pitchAngleAccel += 1.0
    rollAngleAccel += 1.6
	
	// Filtro complementario
	if setGyroAngles {
		pitchAngle = pitchAngle * 0.9 + pitchAngleAccel * 0.1
		rollAngle = rollAngle * 0.9 + rollAngleAccel * 0.1
	} else {
		pitchAngle = pitchAngleAccel
		rollAngle = rollAngleAccel
		setGyroAngles = true
	}
    
	pitchOut = pitchAngle
	rollOut = rollAngle
	yawOut = yawAngle
    
    let pitchString = String(format: "%.1f", pitchOut)
    let rollString = String(format: "%.1f", rollOut)
    let yawString = String(format: "%.1f", yawOut)
    let tempString = String(format: "%.1f", t)
    
    let deltaTimePos = positionTempo.Delta
    Vx += Double(ax)/4096 * deltaTimePos // 4096 Constante de escalamiento
    Vy += Double(ay)/4096 * deltaTimePos // depende del rango seleccionado
    Vz += Double(az)/4096 * deltaTimePos // Leer datasheet
    
    x += Vx * deltaTimePos
    y += Vy * deltaTimePos
    z += Vz * deltaTimePos
    
    let xText = String(format: "%.1f", x)
    let yText = String(format: "%.1f", y)
    let zText = String(format: "%.1f", z)
    
    print("\(pitchString)\t\(rollString)\t\(yawString)\t\(xText)m\t\(yText)m\t\(zText)m\t\(tempString)ºC", terminator:"\r")

}
