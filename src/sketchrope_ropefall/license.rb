require "base64"
require 'date'

module SKETCHROPE_ROPEFALL

LIC_TOKEN_SEPARATOR ||= '_'

def self.clearAppVariables()
    Sketchup.write_default APPNAME, "appId", ""
    Sketchup.write_default APPNAME, "licKey", ""    
end

def self.getUserId()
    isWin = Sketchup.platform == :platform_win
    user =( isWin ? ENV["USERNAME"] : ENV["USER"] )
    encodedUser = Base64.strict_encode64(user)
    
    return encodedUser
end    
   
def self.genRndAppId()
    rId = rand(100000000)
    
    return Base64.strict_encode64(rId.to_s)
end   

def self.retrieveAppId()
    appId = Sketchup.read_default APPNAME, "appId", ""
    
    if (appId != "")
        return appId
    end
    
    appId = genRndAppId()
    Sketchup.write_default APPNAME, "appId", appId
    
    return appId
end

def self.encodeLicBase(licBase)
    tokens = licBase.split(LIC_TOKEN_SEPARATOR)
    
    if (tokens.size() != 4)
        return false
    end
    
    i_ver = tokens[0]
    i_userid = tokens[1]
    i_appId = tokens[2]
    i_LastDayValidDate = tokens[3]

    puts "version = " + Base64.strict_decode64(i_ver)
    puts "userId = " + Base64.strict_decode64(i_userid)
    puts "appId = " + Base64.strict_decode64(i_appId)
    puts "LastDayValidDate = " + Base64.strict_decode64(i_LastDayValidDate)
end

def self.genLastDayValidDate(lastDayValidDate)
    lastDayValidDateStr = lastDayValidDate.to_s 
    
    return Base64.strict_encode64(lastDayValidDateStr)
end

def self.genVersion(version)
    return Base64.strict_encode64(version)
end

def self.genLicenceBase(version, lastDayValidDate)
    return genVersion(version) + LIC_TOKEN_SEPARATOR + getUserId() + LIC_TOKEN_SEPARATOR + retrieveAppId() + LIC_TOKEN_SEPARATOR + genLastDayValidDate(lastDayValidDate)
end
    
def self.sign(licBase)
    toSign = licBase + licBase
    
    return Base64.strict_encode64(jhash(toSign).to_s)
end   

def self.genLicKey(licbase)
    signhash = sign(licbase)
    
    return licbase + LIC_TOKEN_SEPARATOR + signhash 
end 

def self.checkLic(license_key)
    tokens = license_key.split(LIC_TOKEN_SEPARATOR)
    
    if (tokens.size() != 5)
        return false
    end
    
    i_ver = tokens[0]
    i_userid = tokens[1]
    i_appId = tokens[2]
    i_LastDayValidDate = tokens[3]
    i_hash = tokens[4]
    
    if (i_userid != getUserId())
        return false
    end
    
    if (i_appId != retrieveAppId())
        return false
    end
    
    if (i_hash != sign(i_ver + LIC_TOKEN_SEPARATOR + i_userid + LIC_TOKEN_SEPARATOR + i_appId + LIC_TOKEN_SEPARATOR + i_LastDayValidDate))
        return false
    end
        
    return true    
end

def self.saveLic(licence_key)
    Sketchup.write_default APPNAME, "licKey", licence_key   
end

def self.retrieveLic()
    lic = Sketchup.read_default APPNAME, "licKey", ""
    
    raise "no licence found" unless lic != ""
    
    return lic
end

def self.isLicAvailable()
    lic = Sketchup.read_default APPNAME, "licKey", ""
    
    return lic != ""
end

def self.retrieveLastDayValidDate()
    lic = retrieveLic()
    
    tokens = lic.split(LIC_TOKEN_SEPARATOR)
    lastDayValidDate = Date.strptime(Base64.strict_decode64(tokens[3]), "%Y-%m-%d")
    
    return lastDayValidDate    
end

def self.isLicCValid(today)
    return today <= self.retrieveLastDayValidDate()
end

def self.installEvalLicIfNonAvailable(today)
    if (isLicAvailable())
        return
    end
    
    evalLicKey = genLicKey(genLicenceBase(VERSION, today + EVAL_PERIOD_DAY))
    saveLic(evalLicKey)    
end

def self.licInfoDialog(today)
    if (isLicAvailable())
        puts "current licence: " + retrieveLic()
    end
    
    lastDayValidDate = retrieveLastDayValidDate()
    offerNewLicense = today > (lastDayValidDate - 30)
    formattedLastDayValidDate = dateOrPerpetual(lastDayValidDate, today)    
    text = "licence valid until: " + formattedLastDayValidDate
    
    if (offerNewLicense)
        text = text + "\n\nDo you want to purchase a new licence now?"
    else
        text = text + "\n\nNo new licence required."
    end
    
    msgboxType = offerNewLicense ? MB_YESNO : MB_OK
    
    result = UI.messagebox(text, msgboxType)    
    
    if (offerNewLicense && result == IDYES)
        newLastDayValid = (today > lastDayValidDate ? today : lastDayValidDate) + 100 * 365
        licence_base = genLicenceBase(VERSION, newLastDayValid)
        puts "new licence_base: " + licence_base
        status = UI.openURL("http://www.sketchrope.com/license/license.php?licence_base=" + licence_base + "&lastDayValid=" + dateOrPerpetual(newLastDayValid, today))
        
        if (status == false)
            UI.messagebox("could not open url")
        end        
    end
end

def self.dateOrPerpetual(date, today)
    if (date - today > 366)
        return "perpetual"
    end
    
    return date.to_s
end

def self.enterNewLicDialog(today)
    prompts = ["New licence key:"]
    values = [""]
    results = UI.inputbox prompts, values, "Enter new licence key"
    return false if not results        

    licence_key = results[0]
    if (checkLic(licence_key))
        saveLic(licence_key)  
        licInfoDialog(today)
    else
        UI.messagebox("invalid licence key", MB_OK)
    end
end        

def self.jhash(str)
    result = 0
    mul = 1
    max_mod = 2**31 - 1

    str.chars.reverse_each do |c|
        result += mul * c.ord
        result %= max_mod
        mul *= 31
    end

    result  
end    
   
################################ Sketchup Extension Licencing ###############################
def self.skpNoLicenceFoundDialog()
    UI.messagebox("No licence found, sorry.", MB_OK)
end   

def self.skpCheckLic()
    ext_id = "ff1f393e-3ddc-4332-9287-417e89f32289" 
    ext_lic = Sketchup::Licensing.get_extension_license(ext_id)
    
    return ext_lic.licensed?
end
    
end
