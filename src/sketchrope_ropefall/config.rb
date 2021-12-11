require 'sketchup.rb'

module SKETCHROPE_ROPEFALL

def self.config()
    return @@config
end

module WhatToDraw
    MIDLINE = "midline"
    TUBE = "tube"
end

class Config
    attr_accessor :radius
    attr_accessor :whatToDraw
    attr_accessor :lengthPercent
    attr_accessor :minMoveDelta
    attr_accessor :noRopePoints
    attr_accessor :massPointMass
    attr_accessor :springConstant
    attr_accessor :springFrictionConstant
    attr_accessor :surfaceFrictionConstant
    attr_accessor :torsionSpringConstant
    attr_accessor :generalFrictionConstant
    attr_accessor :animIterCount
    attr_accessor :minAnimIterCount
    attr_accessor :dt

    def initialize()
        @radius = 0.125
        @whatToDraw = WhatToDraw::MIDLINE
        @lengthPercent = 1.25
        @animIterCount = 800
        @minAnimIterCount = 100
        @minMoveDelta = SKETCHROPE_ROPEFALL::minMoveDelta
        @noRopePoints = SKETCHROPE_ROPEFALL::noRopePoints
        @massPointMass = SKETCHROPE_ROPEFALL::massPointMass
        @springConstant = SKETCHROPE_ROPEFALL::springConstant
        @springFrictionConstant = SKETCHROPE_ROPEFALL::springFrictionConstant
        @surfaceFrictionConstant = SKETCHROPE_ROPEFALL::surfaceFrictionConstant
        @torsionSpringConstant = SKETCHROPE_ROPEFALL::torsionSpringConstant
        @generalFrictionConstant = SKETCHROPE_ROPEFALL::generalFrictionConstant
        @dt = SKETCHROPE_ROPEFALL::dt
    end
        
end

@@config = Config.new

end
