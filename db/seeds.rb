PaperTrail.enabled = false

Room.create(name: 'Stage')
Room.create(name: 'Larkum Studio')
Room.create(name: 'Dressing Room 1')
Room.create(name: 'Dressing Room 2')
Room.create(name: 'Bar')
User.create(name: "Charlie Jonas", email: "charlie@charliejonas.co.uk", admin: true, blocked: false)
ProviderAccount.create(provider: "camdram", uid: "3807", user_id: 1)
