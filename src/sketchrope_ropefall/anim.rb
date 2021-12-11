require 'sketchup.rb'
Sketchup::require "sketchrope_ropefall/constants"

module SKETCHROPE_ROPEFALL

class Anim
    def initialize(initialPoints, config)
        @torsionSpringVectorBegin = (initialPoints[0] - initialPoints[1]).normalize
        @torsionSpringVectorEnd = (initialPoints[-2] - initialPoints[-1]).normalize
        @rope = Rope.new(initialPoints, polylineLength(initialPoints) * config.lengthPercent, config.radius, config.noRopePoints, config.massPointMass, config.springConstant, config.springFrictionConstant, config.surfaceFrictionConstant, @torsionSpringVectorBegin, @torsionSpringVectorEnd, SKETCHROPE_ROPEFALL::torsionSpringConstant) 
        @ropeGroup = SKETCHROPE_ROPEFALL::entities.add_group
        @count = config.animIterCount
        @minCount = config.animIterCount - config.minAnimIterCount
        @dt = config.dt
        @dtFactor = 1
        @stopped = false
        @picSerNum = 100
    end
    
    def polylineLength(initialPoints)
        last = nil
        len = 0
        initialPoints.each{|p| 
            if (last != nil) 
               len = len + last.distance(p) 
            end
            
            last = p
        }
        
        return len
    end
    
    def stop()
        @stopped = true
    end
    
    def nextFrame(view)
        @rope.solve()
        
        maxVelPctChange = @rope.maxVelPctChange
        
        raise "maxVelPctChange < 0" unless maxVelPctChange >= 0
            
        
#        @dtFactor = @dtFactor * (1 - (maxVelPctChange - 0.6) * 0.1)
        
        if (maxVelPctChange < 0.3)
            @dtFactor = @dtFactor * 2
        end

        if (maxVelPctChange > 0.7)
            @dtFactor = @dtFactor * 0.5
        end

        @dtFactor = SKETCHROPE_ROPEFALL::max(0.5, @dtFactor)
        @dtFactor = SKETCHROPE_ROPEFALL::min(2, @dtFactor)
        
        dt = @dt * @dtFactor         
        
        
        @rope.simulate(dt)
        
        points = SKETCHROPE_ROPEFALL::ropePoints(@rope)
        @ropeGroup.entities.clear!
        # todo use view to draw temporarily
        edges = @ropeGroup.entities.add_curve points        
        #view.draw_polyline points

        @count = @count - 1
        
        view.show_frame()
        
        if (SKETCHROPE_ROPEFALL::writeAnim())
            writeView(view, @picSerNum)
            @picSerNum = @picSerNum + 1
        end

#        finished = @count < @minCount && (@count == 0 || !@rope.hasAnyMoved())
        finished = @stopped || @count == 0 || !@rope.hasAnyMoved()

        if (finished)
            finish(view, points)
	    end
        
        return !finished
    end    
   
    def finish(view, points)
        @ropeGroup.entities.clear!
        @ropeGroup.erase!

        points.each{|p|
            puts "points << Geom::Point3d.new(" + String(p.x().to_inch()) + ", " + String(p.y().to_inch()) + ", " + String(p.z().to_inch()) + ");"
        }

        @ropeGroup = SKETCHROPE_ROPEFALL::entities.add_group
        points_chunk = points[0..99]
        edges = @ropeGroup.entities.add_curve points_chunk  
        
        if (SKETCHROPE_ROPEFALL::config().whatToDraw == SKETCHROPE_ROPEFALL::WhatToDraw::TUBE)
            cirlce = @ropeGroup.entities.add_circle points_chunk[0], points_chunk[0] - points_chunk[1], SKETCHROPE_ROPEFALL::config.radius
        	face = @ropeGroup.entities.add_face cirlce
            face.followme(edges)
        end

        if (SKETCHROPE_ROPEFALL::writeAnim())
            for i in 1..30
                writeView(view, @picSerNum)
                @picSerNum = @picSerNum + 1
            end
        end

        SKETCHROPE_ROPEFALL::entities.each{|e| 
            if (e.is_a?(Sketchup::Group) && e.name == COLLISIONGROUPNAME) 
                e.erase!                
            end
        }
        Sketchup.active_model.layers.remove(DUPLAYERNAME)        
        Sketchup.active_model.select_tool nil    
        Sketchup.status_text = "Ropefall ready."
    end 
    
    def writeView(view, i)
        keys = {
           :filename => "/home/torel/work/sketchrope/ropefall/anim/ropefall" + i.to_s + ".png",
           :width => 400,
           :height => 400,
           :antialias => true,
           :compression => 0.9,
           :transparent => true
         }
         
       view.write_image keys
    end
end

end
