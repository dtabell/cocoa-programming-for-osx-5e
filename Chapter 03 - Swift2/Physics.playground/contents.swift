import Cocoa

struct Vector: CustomStringConvertible {
    var x: Double
    var y: Double
    
    init() {
        self.init(x: 0, y: 0)
    }
    init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
    
    func vectorByAddingVector(vector: Vector) -> Vector {
        return Vector(x: x + vector.x,
            y: y + vector.y)
    }

    var magnitude: Double {
        return hypot(x, y)
    }
    
    var description: String {
        return "(\(x), \(y))"
    }
    
}

func +(left: Vector, right: Vector) -> Vector {
    return left.vectorByAddingVector(right)
}
func *(left: Vector, right: Double) -> Vector {
    return Vector(x: left.x * right , y: left.y * right)
}
func *(left: Double, right: Vector) -> Vector {
    return right * left
}

class Particle {
    
    var position: Vector
    var velocity: Vector
    var acceleration: Vector
    
    init(position: Vector) {
        self.position = position
        self.velocity = Vector()
        self.acceleration = Vector()
    }
    
    convenience init() {
        self.init(position: Vector())
    }

    func tick(dt: NSTimeInterval) {
        // second-order accurate integration
        let hdt = 0.5 * dt
        position = position + velocity * hdt
        velocity = velocity + acceleration * dt
        position = position + velocity * hdt
        position.y = max(0, position.y)
    }
}

class Rocket: Particle {
    let thrust: Double
    var thrustTimeRemaining: NSTimeInterval
    let direction = Vector(x: 0, y: 1)
    
    convenience init(thrust: Double, thrustTime: NSTimeInterval) {
        self.init(position: Vector(), thrust: thrust, thrustTime: thrustTime)
    }
    
    init(position: Vector, thrust: Double, thrustTime: NSTimeInterval) {
        self.thrust = thrust
        self.thrustTimeRemaining = thrustTime
        super.init(position: position)
    }
    
    override func tick(dt: NSTimeInterval) {
        if thrustTimeRemaining > 0.0 {
            let thrustTime = min(dt, thrustTimeRemaining)
            let thrustFrac = thrust * (thrustTime / dt)
            acceleration = acceleration + thrustFrac * direction
            thrustTimeRemaining -= thrustTime
        }
        super.tick(dt)
    }
}

let gravity = Vector(x: 0, y: -9.8) // meters per second
let twoGs = gravity.vectorByAddingVector(gravity)
let twoGsAlso = gravity * 2

class Simulation {
    var particles: [Particle] = []
    var time: NSTimeInterval = 0.0

    func addParticle(particle: Particle) {
        particles.append(particle)
    }
    
    func tick(dt: NSTimeInterval) {
        for particle in particles {
            particle.acceleration = gravity
            particle.tick(dt)
            particle.position.y
        }
        time += dt
        particles = particles.filter { particle in
            let live = particle.position.y > 0.0
            if !live {
                print("Terminated at time \(self.time)")
            }
            return live
        }
    }
    
}

let simulation = Simulation()

//let ball = Particle()
//ball.velocity = Vector(x: 0, y: 100)
//simulation.addParticle(ball)

let rocket = Rocket(thrust: 10.0, thrustTime: 60.0)
simulation.addParticle(rocket)


while simulation.particles.count > 0 && simulation.time < 500 {
    simulation.tick(1.0)
}

print("Gravity is \(gravity).")


