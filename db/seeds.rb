PaperTrail.enabled = false

Venue.create(name: 'Stage')
Venue.create(name: 'Larkum Studio')
Venue.create(name: 'Dressing Room 1')
Venue.create(name: 'Dressing Room 2')
Venue.create(name: 'Bar')
User.create(name: "Charlie Jonas", email: "charlie@charliejonas.co.uk", admin: true, blocked: false)
ProviderAccount.create(provider: "camdram", uid: "3807", user_id: 1)
