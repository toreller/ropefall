require 'sketchup.rb'

Sketchup::require 'sketchrope_ropefall/constants'
Sketchup::require 'sketchrope_ropefall/util'
Sketchup::require 'sketchrope_ropefall/grid'
Sketchup::require 'sketchrope_ropefall/model'
Sketchup::require 'sketchrope_ropefall/config'
Sketchup::require 'sketchrope_ropefall/anim'
Sketchup::require 'sketchrope_ropefall/ui'
Sketchup::require 'sketchrope_ropefall/test'
Sketchup::require 'sketchrope_ropefall/license'

module SKETCHROPE_ROPEFALL

def reload()
	Sketchup.load 'sketchrope_ropefall/constants'
	Sketchup.load 'sketchrope_ropefall/util'
	Sketchup.load 'sketchrope_ropefall/grid'
	Sketchup.load 'sketchrope_ropefall/model'
    Sketchup.load 'sketchrope_ropefall/config'
    Sketchup.load 'sketchrope_ropefall/anim'
	Sketchup.load 'sketchrope_ropefall/ui'
	Sketchup.load 'sketchrope_ropefall/test'
	Sketchup.load 'sketchrope_ropefall/license'
end

def self.drawResult(i, points)
   	dir = "/home/torel/work/cable/export/"

    layername = "reslayer_" + (i+1).to_s
    
    @@entities.add_edges points 
    cpoint_group = @@entities.add_group
    points.each{|p| cpoint_group.entities.add_cpoint p}
	@@model.active_view.write_image(dir + "/" + layername + ".png")
    cpoint_group.erase!
end

def self.printPoints(name, points)
    puts name
    points.each{ |p| puts p.to_s}    
end


def self.run()
    #reload() 
    SKETCHROPE_ROPEFALL::installEvalLicIfNonAvailable(Date.today)
    intallCommands() 
    
    #initialPoints = [Geom::Point3d.new(-500.mm, 0, 100.mm), Geom::Point3d.new(-100.mm, 300.mm, 100.mm), Geom::Point3d.new(100.mm, -300.mm, 100.mm), Geom::Point3d.new(900.mm, 0, 300.mm)]
    #SKETCHROPE_ROPEFALL::entities.add_edges initialPoints
    #self.testAnimWithBlockade()
end

end

SKETCHROPE_ROPEFALL.run()

