class Event < ActiveRecord::Base
    def self.availabilities(date)
        dates = []
        result = []

        for i in 0..6 do
            dates << Date.new(date.year, date.month, date.day + i).strftime("%Y-%m-%d")    #On crée les dates a check
        end

        weekly_recurring_events = Event.where(weekly_recurring: true)
        dates.each do |day|
            day_opening_events = Event.where(starts_at: day.to_datetime..(day.to_datetime + 1.day)).where(kind: 'opening')
            day_appointment_events = Event.where(starts_at: day.to_datetime..(day.to_datetime + 1.day)).where(kind: 'appointment')
            weekly_to_inject = []
            weekly_recurring_events.each do |weekly_event|
                weekly_to_inject << weekly_event if(day.to_date.wday == weekly_event.starts_at.wday) #ajoute l'opening recurrent si on est au meme jour de la semaine que celui-ci
            end
            day_opening_events += weekly_to_inject
            day_slots_dispos = []

            day_opening_events.each do |open_event| #On boucle sur les event de type 'opening'
                date_time = open_event.starts_at
                while date_time < open_event.ends_at   #On feed l'array de slot de 30min en partant de 'starts_at' jusqu'a arriver à 'ends_at'
                    day_slots_dispos << date_time
                    date_time += 30.minute
                end
            end
            
            day_appointment_events.each do |appoint_event|  #Puis on boucle sur les events de type 'appointment' on delete tout ce qu'il y a entre 
                day_slots_dispos.delete_if { |slot| slot.strftime("%R") >= appoint_event.starts_at.strftime("%R") && slot.strftime("%R") < appoint_event.ends_at.strftime("%R")}    # on delete tout les elements qu'il y a entre starts_at et ends_at
            end
            #Plus qu'a map la 'date' à 'day_slots_dispos'
            result << { :date => day.to_date, :slots => day_slots_dispos.map { |slot| slot.strftime(slot.hour.to_s + ":%M") }}  #On feed result en formatant les slots dispos comme demandés
        end
        return result
    end
end
