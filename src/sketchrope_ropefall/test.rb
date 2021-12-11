require "sketchup.rb"
Sketchup::require "sketchrope_ropefall/constants"
Sketchup::require "sketchrope_ropefall/model"

module SKETCHROPE_ROPEFALL

def self.horizontalFace(t, w, d)
    faceGroup = SKETCHROPE_ROPEFALL::entities.add_group
	face = faceGroup.entities.add_face t * Geom::Point3d.new(-w / 2, -d / 2, 0), t * Geom::Point3d.new(-w / 2, d / 2, 0), t * Geom::Point3d.new(w / 2, d / 2, 0), t * Geom::Point3d.new(w / 2, -d / 2, 0)

	return faceGroup	
end

def self.box(t, w, d, l)
    faceGroup = SKETCHROPE_ROPEFALL::entities().add_group
	face = faceGroup.entities.add_face t * Geom::Point3d.new(-w / 2, -d / 2, 0), t * Geom::Point3d.new(-w / 2, d / 2, 0), t * Geom::Point3d.new(w / 2, d / 2, 0), t * Geom::Point3d.new(w / 2, -d / 2, 0)
    	
	face.pushpull l
end

def self.cylinder(t, r, l, n)
        cirlce = SKETCHROPE_ROPEFALL::entities().add_circle t * Geom::Point3d.new(0, 0, 0), t * Geom::Vector3d.new(0, 1, 0), r, n        
    	face = SKETCHROPE_ROPEFALL::entities().add_face cirlce
    	
    	face.pushpull l
end

def self.testCollision()
    horizontalFace(identityTrans, 1.m, 1.m)    
    horizontalFace(Geom::Transformation.translation(Geom::Vector3d.new(0, 0, -50.mm)), 1.m, 1.m)    
    mp = MassPoint.new(1, Geom::Point3d.new(0, 0, 100.mm))
    SKETCHROPE_ROPEFALL::entities().add_cpoint mp.pos
    
    mp.applyForce(Geom::Vector3d.new(0, 0, -20.m))
    mp.simulate(0.1)
    SKETCHROPE_ROPEFALL::entities().add_cpoint mp.pos    
end

def self.testSpringSections()
    initialPoints = [Geom::Point3d.new(-500.mm, 0, 100.mm), Geom::Point3d.new(0, 100.mm, 100.mm), Geom::Point3d.new(500.mm, 0, 300.mm)]
    rope = Rope.new(initialPoints, 1.m, @@noRopePoints, @@massPointMass, @@springConstant, @@springFrictionConstant, @@surfaceFrictionConstant) 
    rope.massPoints.each{|mp| @@entities.add_cpoint mp.pos}
    @@entities.add_edges initialPoints
end

def self.testRopeCorrectsShape()
    t = Geom::Transformation.translation(Geom::Vector3d.new(0, 0, -0.3.m)) * Geom::Transformation.rotation(Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(0, 1, 0), 30.degrees)
    horizontalFace(t, 0.2.m, 0.2.m)
    horizontalFace(Geom::Transformation.translation(Geom::Vector3d.new(0, 0, -0.4.m)), 1.m, 1.m)
    initialPoints = [Geom::Point3d.new(-500.mm, 0, 100.mm), Geom::Point3d.new(-100.mm, 300.mm, 100.mm), Geom::Point3d.new(100.mm, -300.mm, 100.mm), Geom::Point3d.new(500.mm, 0, 300.mm)]
    SKETCHROPE_ROPEFALL::entities.add_edges initialPoints
    rope = Rope.new(initialPoints, 1.5.m, 5.mm, SKETCHROPE_ROPEFALL::noRopePoints, SKETCHROPE_ROPEFALL::massPointMass, SKETCHROPE_ROPEFALL::springConstant, SKETCHROPE_ROPEFALL::springFrictionConstant, SKETCHROPE_ROPEFALL::surfaceFrictionConstant) 
    ropeGroup = SKETCHROPE_ROPEFALL::entities.add_group
    
    i = 0;
    while (i < 50) do
        rope.solve()
        rope.simulate(0.1)

        rope.massPoints.each{|mp| @@entities.add_cpoint mp.pos}
        @@entities.add_edges ropePoints(rope)
        
        i = i + 1
    end
end

class AnimTest 
    def initialize()
        initialPoints = [Geom::Point3d.new(-500.mm, 0, 100.mm), Geom::Point3d.new(-100.mm, 300.mm, 100.mm), Geom::Point3d.new(100.mm, -300.mm, 100.mm), Geom::Point3d.new(900.mm, 0, 300.mm)]
        SKETCHROPE_ROPEFALL::entities.add_edges initialPoints
         @torsionSpringVectorBegin = Geom::Vector3d.new(-1, 0, 0)
         @torsionSpringVectorEnd = Geom::Vector3d.new(1, 0, 0)         
        @rope = Rope.new(initialPoints, 3.5.m, 4.mm, SKETCHROPE_ROPEFALL::noRopePoints, SKETCHROPE_ROPEFALL::massPointMass, SKETCHROPE_ROPEFALL::springConstant, SKETCHROPE_ROPEFALL::springFrictionConstant, SKETCHROPE_ROPEFALL::surfaceFrictionConstant, @torsionSpringVectorBegin, @torsionSpringVectorEnd, SKETCHROPE_ROPEFALL::torsionSpringConstant) 
        @ropeGroup = SKETCHROPE_ROPEFALL::entities.add_group
        @count = 25
    end

    def nextFrame(view)
        @rope.solve()
        @rope.simulate(0.05)
        
        @ropeGroup.entities.clear!
        points = SKETCHROPE_ROPEFALL::ropePoints(@rope)
        edges = @ropeGroup.entities.add_curve points        

        @count = @count - 1
        
        view.show_frame()

        if (@count == 0)
            cirlce = @ropeGroup.entities.add_circle points[0], points[1] - points[0], 4.mm
        	face = @ropeGroup.entities.add_face cirlce
	        face.followme(edges)
	    end
        
        return @count > 0
    end    
end

def self.testAnimWithBlockade()
    t = Geom::Transformation.translation(Geom::Vector3d.new(0, 0, -0.3.m)) * Geom::Transformation.rotation(Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(0, 1, 0), 20.degrees)
    box(t, 0.2.m, 0.2.m, 0.05.m)
    horizontalFace(Geom::Transformation.translation(Geom::Vector3d.new(0, 0, -0.4.m)), 2.m, 2.m)
    cylinder(Geom::Transformation.translation(Geom::Vector3d.new(0.2.m, -0.5.m, -0.3.m)), 0.09.m, 1.m, 12)    
    #@@model.active_view.animation = AnimTest.new     
end

def self.testDistanceToFace()
    t = Geom::Transformation.translation(Geom::Vector3d.new(0, 0, -0.3.m)) * Geom::Transformation.rotation(Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(0, 1, 0), 30.degrees)
    horizontalFace(t, 0.2.m, 0.2.m)
    horizontalFace(Geom::Transformation.translation(Geom::Vector3d.new(0, 0, -0.4.m)), 1.m, 1.m)

    allFaces = getAllFaces()

    p = Geom::Point3d.new(0, 0, 0.5.m)


    r = self.getClosestFace(p, allFaces)
    distance = r[0]
    projected_p = r[1]

    @@entities.add_cpoint p
    @@entities.add_cpoint projected_p
    @@entities.add_cline p, projected_p 
    
    puts "closest point: " + projected_p.to_s
    
    p = Geom::Point3d.new(0.3.m, 0.3.m, -0.15.m)
    r = self.getClosestFace(p, allFaces)
    distance = r[0]
    projected_p = r[1]

    @@entities.add_cpoint p
    @@entities.add_cpoint projected_p
    @@entities.add_cline p, projected_p 
end

def self.testCross()
    t = Geom::Transformation.translation(Geom::Vector3d.new(0, 0, -0.3.m)) * Geom::Transformation.rotation(Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(0, 1, 0), 20.degrees)
    horizontalFace(t, 0.2.m, 0.2.m)
    allFaces = getAllFaces()

    from = Geom::Point3d.new(0, 0, 0)
    to = Geom::Point3d.new(0, 0, -0.5.m)
    @@entities.add_cline from, to
    allFaces.each{|f|
        res = isFaceCrossed(from, to, 0.2.m, f)
        if (res[0] != nil)
            @@entities.add_cpoint res[2]
            @@entities.add_cline res[1], res[2]
        end
    }    

    from = Geom::Point3d.new(0.05.m, 0, 0)
    to = Geom::Point3d.new(0.05.m, 0, -0.2.m)
    @@entities.add_cline from, to
    allFaces.each{|f|
        res = isFaceCrossed(from, to, 0.2.m, f)
        
        if (res[0] != nil)
            @@entities.add_cpoint res[2]
            @@entities.add_cline res[1], res[2]
        end
    }    

    from = Geom::Point3d.new(0.15.m, 0, 0)
    to = Geom::Point3d.new(0.15.m, 0, -0.5.m)
    @@entities.add_cline from, to
    allFaces.each{|f|
        res = isFaceCrossed(from, to, 0.2.m, f)
        @@entities.add_cpoint res[2]
        @@entities.add_cline res[1], res[2]
    }    

    from = Geom::Point3d.new(-0.35.m, 0, 0)
    to = Geom::Point3d.new(-0.35.m, 0, -0.5.m)
    @@entities.add_cline from, to
    allFaces.each{|f|
        res = isFaceCrossed(from, to, 0.2.m, f)
        
        if (res[0] != nil)
            @@entities.add_cpoint res[2]
            @@entities.add_cline res[1], res[2]
        end
    }    
end

def self.testCylinderCollision()
   t = Geom::Transformation.translation(Geom::Vector3d.new(0, 0, -0.3.m)) * Geom::Transformation.rotation(Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(0, 1, 0), 20.degrees)
    box(t, 0.2.m, 0.2.m, 0.05.m)
    horizontalFace(Geom::Transformation.translation(Geom::Vector3d.new(0, 0, -0.4.m)), 2.m, 2.m)
 
    r = 20.mm
    from = Geom::Point3d.new(-100.mm, 0, -200.mm)
    to = Geom::Point3d.new(-250.mm, 0, -350.mm)   
    p0 = Geom::Point3d.new(100.mm, 0, -250.mm)   
    
    drawVector(from, to)
    @@entities.add_cpoint p0
     
    p_cut = cylinderCollisionPoint(from, to, p0, r)
    if (p_cut != nil)
        @@entities.add_cpoint p_cut
    end
    
 
end

end
