require 'sketchup.rb'
Sketchup::require 'sketchrope_ropefall/config'

module SKETCHROPE_ROPEFALL

class RopefallTool
    def initialize(initialPoints, config)
        @initialPoints = initialPoints
        @config = config
    end

    def activate
        SKETCHROPE_ROPEFALL::model().start_operation(SKETCHROPE_ROPEFALL::ROPEFALL, false, false, false)
        SKETCHROPE_ROPEFALL::startFall(@initialPoints, @config)
    end

    def deactivate(view)
        SKETCHROPE_ROPEFALL::model().commit_operation()
    end

    def onCancel(flag, view)
        SKETCHROPE_ROPEFALL::stopFall()
    end    
    
    def reset()
        @initialPoints = nil
        @config = nil
    end
end

def self.createFallCommand()
    @@falling = false
    cmd = UI::Command.new("fall") {
        fallCommand()
        }
    cmd.menu_text = SKETCHROPE_ROPEFALL::FALL
    cmd.set_validation_proc {
    }
    
    return cmd
end

def self.createLicInfoCommand()
    cmd = UI::Command.new("licinfo") {
        licInfoDialog(Date.today)
        }
    cmd.menu_text = "Request licence"
    cmd.set_validation_proc {
    }
    
    return cmd
end

def self.createNewLicCommand()
    cmd = UI::Command.new("newlic") {
        enterNewLicDialog(Date.today)
        }
    cmd.menu_text = "Enter licence key"
    cmd.set_validation_proc {
    }
    
    return cmd
end

def self.fallCommand()
    today = Date.today
    
    if (isLicCValid(today))
        activateFall()
    else
        licInfoDialog(today)
    end
end

def self.activateFall()
    begin
        initialPoints = getInitialPointsFromSelection()
        
        if (initialPoints != nil)
            if (showConfigInputBox())
                Sketchup.active_model.select_tool RopefallTool.new(initialPoints, SKETCHROPE_ROPEFALL::config)
            end
        end
    rescue Exception => msg
        puts msg
        Sketchup.active_model.select_tool null
    end
end

def self.intallCommands() 
 if not file_loaded?(__FILE__) 
    submenu = UI.menu("Draw").add_submenu(SKETCHROPE_ROPEFALL::ROPEFALL)
    
    submenu.add_item(createFallCommand())
    submenu.add_separator
    submenu.add_item(createLicInfoCommand())
    submenu.add_item(createNewLicCommand())
 end
 
 file_loaded(__FILE__) 
end

def self.showConfigInputBox()
    prompts = ["Rope diameter:", "What to draw:"]
    defaults = [(SKETCHROPE_ROPEFALL::config().radius * 2).to_l, SKETCHROPE_ROPEFALL::config().whatToDraw]
    lists = ["", WhatToDraw::MIDLINE + "|" + WhatToDraw::TUBE]
    results = UI.inputbox prompts, defaults, lists, SKETCHROPE_ROPEFALL::ROPEFALL + " parameters"
    return false if not results        
    
    SKETCHROPE_ROPEFALL::config().radius = results[0] / 2
    SKETCHROPE_ROPEFALL::config().whatToDraw = results[1]
    
    return true
end

def self.startFall(initialPoints, config)     
    @@anim = Anim.new(initialPoints, config) 
    SKETCHROPE_ROPEFALL::model.active_view.animation = @@anim
end

def self.stopFall()     
    if (@@anim != nil)     
        @@anim.stop()
        @@anim = nil
    end
end

def self.getInitialPointsFromSelection()
    initialPoints = SKETCHROPE_ROPEFALL::sortSelection()
    
    if (initialPoints == nil || initialPoints.length < 2) 
        UI.messagebox("Please create an open polyline and then select it!")
        
        return nil
    end
    
    if (!isInitialPointAboveBottom(initialPoints))
        UI.messagebox("Initial polyline must be above the bottom of the model!")

        return nil
    end

    return initialPoints
end

def self.isInitialPointAboveBottom(initialPoints)
    modelBounds = SKETCHROPE_ROPEFALL::model.bounds
    bottom = modelBounds.min.z
    initialPoints.each{|p| 
        if (p.z <= bottom + EPSILON)
            return false
        end
    }
    
    return true
end

def self.addOrRemoveEndpoint(endpoints, p)
    if (endpoints.include?(p))
        endpoints.delete(p)
    else
        endpoints << p
    end
end

def self.printEdge(e) 
    puts "start = " + e.start.position.to_s + ", end = " + e.end.position.to_s
end

end
