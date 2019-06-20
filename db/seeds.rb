PaperTrail.enabled = false

adc = CamdramVenue.create(camdram_id: 29) # ADC Theatre
bar = CamdramVenue.create(camdram_id: 68) # ADC Theatre (Bar)
larkum = CamdramVenue.create(camdram_id: 69) # ADC Theatre (Larkum Studio)
playroom = CamdramVenue.create(camdram_id: 30) # Corpus Playroom
adc_venues = [adc, bar, larkum]
playroom_venues = [playroom]

Room.create(name: 'Stage', camdram_venues: adc_venues)
Room.create(name: 'Larkum Studio', camdram_venues: adc_venues)
Room.create(name: 'Dressing Room 1', camdram_venues: adc_venues)
Room.create(name: 'Dressing Room 2', camdram_venues: adc_venues)
Room.create(name: 'Bar', camdram_venues: adc_venues)
Room.create(name: 'Playroom Auditorium', camdram_venues: playroom_venues)
Room.create(name: 'Playroom Dressing Room 1', camdram_venues: playroom_venues)
Room.create(name: 'Playroom Dressing Room 2', camdram_venues: playroom_venues)

User.create(name: "Charlie Jonas", email: "charlie@charliejonas.co.uk", admin: true, sysadmin: true, blocked: false)
ProviderAccount.create(provider: "camdram", uid: "3807", user_id: 1)
