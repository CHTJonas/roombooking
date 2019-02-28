PaperTrail.enabled = false

Room.create(name: 'Stage', camdram_venues: ['adc-theatre', 'adc-theatre-larkum-studio', 'adc-theatre-bar'])
Room.create(name: 'Larkum Studio', camdram_venues: ['adc-theatre', 'adc-theatre-larkum-studio', 'adc-theatre-bar'])
Room.create(name: 'Dressing Room 1', camdram_venues: ['adc-theatre', 'adc-theatre-larkum-studio', 'adc-theatre-bar'])
Room.create(name: 'Dressing Room 2', camdram_venues: ['adc-theatre', 'adc-theatre-larkum-studio', 'adc-theatre-bar'])
Room.create(name: 'Bar', camdram_venues: ['adc-theatre', 'adc-theatre-larkum-studio', 'adc-theatre-bar'])
Room.create(name: 'Playroom Auditorium', camdram_venues: ['corpus-playroom'])
Room.create(name: 'Playroom Dressing Rooms', camdram_venues: ['corpus-playroom'])
User.create(name: "Charlie Jonas", email: "charlie@charliejonas.co.uk", admin: true, sysadmin: true, blocked: false)
ProviderAccount.create(provider: "camdram", uid: "3807", user_id: 1)
