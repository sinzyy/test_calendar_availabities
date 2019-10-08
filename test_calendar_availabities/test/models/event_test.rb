require 'test_helper'

class EventTest < ActiveSupport::TestCase

  test "one simple test example" do
    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-04 09:30"), ends_at: DateTime.parse("2014-08-04 12:30"), weekly_recurring: true
    Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-11 10:30"), ends_at: DateTime.parse("2014-08-11 11:30")

    # Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-11 09:30"), ends_at: DateTime.parse("2014-08-11 12:30"), weekly_recurring: true
    # Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-11 10:30"), ends_at: DateTime.parse("2014-08-11 11:30")

    #2014-08-11 -> 09H30 - 12H30 = opening --- 10H30 - 11H30 -> appointment
    availabilities = Event.availabilities DateTime.parse("2014-08-10")
    assert_equal Date.new(2014, 8, 10), availabilities[0][:date]  #check que le premier element de l'array est la date parametre
    assert_equal [], availabilities[0][:slots]  #check qu'il n'y ai pas de slots dispos pour la premiere date
    assert_equal Date.new(2014, 8, 11), availabilities[1][:date]  #check que le deuxieme élément de l'array est le lendemain de la date parametre
    assert_equal ["9:30", "10:00", "11:30", "12:00"], availabilities[1][:slots]
    assert_equal Date.new(2014, 8, 16), availabilities[6][:date]  #check que le dernier element de l'array est bien la date param + 7j
    assert_equal 7, availabilities.length #check que la fonction check bien les 7 jours
  end

end
