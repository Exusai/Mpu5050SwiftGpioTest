//Imports
import SwiftyGPIO
import MPU6050
import Foundation

//Init the MPU6050 and HW
let i2cs = SwiftyGPIO.hardwareI2Cs(for:.RaspberryPi3)!
let i2c = i2cs[1]

let mp = MPU6050(i2c)

mp.enable(true)

//Actual code
var gyroX: Int = 0
var gyroY: Int = 0
var gyroZ: Int = 0

var gxCal: Int = 0
var gyCal: Int = 0
var gzCal: Int = 0

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
//while(true){
    //let (ax,ay,az,t,gx,gy,gz) = mp.getAll()
    //print("Accelerometer - x:\(ax),y:\(ay),z:\(az)")
    //print("Gyroscope - x:\(gx),y:\(gy),z:\(gz)")
    //print("Temperature(°c): \(t)")
    //sleep(1)
//}

/// CALIBRATING ///
print("Calibrating")
for n in 0...2000 {
	if n % 125 == 0 {
		print(".")
	}
	let (_,_,_,_,gx,gy,gz) = mp.getAll()
	gxCal += gx
	gyCal += gy
	gzCal += gz
	//usleep(200)
}
gxCal = gxCal / 2000
gyCal = gyCal / 2000
gzCal = gzCal / 2000
print("gxAverage: \(gxCal) gyAverage: \(gyCal) gzAverage: \(gzCal) ")
print("Calibrated")

/// Readings ////
var time = NSDate()
var refreshRate: Double = 100
/// Headers for printing
print("Pitch\tRoll\tYaw\tTemp")
while(true){
	let (ax, ay, az, t, gx, gy, gz) = mp.getAll()
	gyroX = gx - gxCal
	gyroY = gy - gyCal
	gyroZ = gz - gzCal
	let newTime = NSDate()
	let deltaTime = newTime.timeIntervalSince(time as Date)
	refreshRate = 1 / deltaTime
	//print("Execution time: \(deltaTime)")
	//print("Refresh Rate: \(refreshRate)")
	time = NSDate()
	//print("Gyroscope - x:\(gyroZ),y:\(gyroY),z:\(gyroZ)")
	//print("Gyroscope - x:\(gx),y:\(gy),z:\(gz)")
	//gyro angle calc
	//0.0000611 = 1 / (250Hz / 65.5)
	let constant1: Double  = 1 / (refreshRate / 0.007685)
	pitchAngle += Double(gyroX) * constant1
	rollAngle += Double(gyroY) * constant1
	yawAngle += Double(gyroZ) * constant1

	//0.000001066 = 0.0000611 * (3.142(PI) / 180degr) apparently the sin func is in rad
	let constant2: Double  = constant1 * (Double.pi / 180)
	pitchAngle += rollAngle * sin(Double(gyroZ) *  constant2)
	rollAngle -= pitchAngle * sin(Double(gyroZ) *  constant2)
	//print("Pitch: \(pitchAngle)")
	//print("Roll: \(rollAngle)")

	//Accel angle calc
	let ax2: Float = Float(ax) * Float(ax)
	let ay2: Float = Float(ay) * Float(ay)
	let az2: Float = Float(az) * Float(az)
	accelVectorMag = Float(sqrt(ax2 + ay2 + az2))
	pitchAngleAccel = asin(Double(Float(ay)/accelVectorMag)) * 57.29
	rollAngleAccel = asin(Double(Float(ax)/accelVectorMag)) * -57.29

	//Calibrate Accel angles
	pitchAngleAccel -= 0.0
	rollAngleAccel += 3.95 + 0.3

	if setGyroAngles {
		pitchAngle = pitchAngle * 0.9996 + pitchAngleAccel * 0.0004
		rollAngle = rollAngle * 0.9996 + rollAngleAccel * 0.0004
	} else {
		pitchAngle = pitchAngleAccel
		rollAngle = rollAngleAccel
		setGyroAngles = true
	}

	pitchOut = pitchOut * 0.9 + pitchAngle * 0.1
	rollOut = rollOut * 0.9 + rollAngle * 0.1
	yawOut = yawAngle
    
    let pitchString = String(format: "%.2f", pitchOut)
    let rollString = String(format: "%.2f", rollOut)
    let yawString = String(format: "%.2f", yawOut)
    let tempString = String(format: "%.2f", t)
    
    /*
	print("Pitch:   \(pitchString)")
	print("Roll:    \(rollString)")
	print("Yaw:     \(yawString)")
    print("Temp:    \(tempString)")*/
    print("\(pitchString)\t\(rollString)\t\(yawString)\t\(tempString)")
}
