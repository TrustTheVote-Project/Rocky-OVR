module StateRegistrants::MIRegistrant::EyeColor
  
# = No Eye Color  
# = Black  
# = Blue  
# = Brown  
# = Green  
# = Gray  
# = Hazel  
# = Maroon  
# = Multicolor  
# = Pink  
  
  CODES = %w(UNK       
            BLK       
            BLU       
            BRO       
            GRN       
            GRY       
            HAZ       
            MAR       
            MUL       
            PNK)     
            
            
  def eye_colors
    CODES.collect {|c| [I18n.t("states.custom.mi.eye_color.#{c}"), c]}
  end          
            

end