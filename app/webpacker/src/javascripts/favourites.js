// Favourite bookings are stored in an indexed database locally in the user's browser.
// This provides a level of isolation for privacy reasons.

const clearFavourites = () => {
    $('#favourite-bookings-spinner').replaceWith('<p class="mt-4 my-3">None!</p>');
};

const showErrorFavourites = () => {
    $('#favourite-bookings-spinner').replaceWith('<p class="mt-4 my-3">An error occurred retrieving favourite bookings!</p>');
};

const appendFavourites = (data) => {
    if (data) {
        $('#favourite-bookings-container').replaceWith(data);
    } else {
        clearFavourites();
    }
};

const setupIDB = () => {
    const DBOpenRequest = indexedDB.open("roombooking", 1);
    DBOpenRequest.onupgradeneeded = (dbOpenEvent) => {
        const db = dbOpenEvent.target.result;
        db.onerror = (e) => {
            console.error(e);
            throw "An error occurred";
        };
        const objectStore = db.createObjectStore("favouriteShows", {
            keyPath: "bookingId"
        });
        objectStore.createIndex("numberOfVisits", "numberOfVisits", {
            unique: false
        });
        objectStore.createIndex("lastVisitDate", "lastVisitDate", {
            unique: false
        });
    };
    return DBOpenRequest;
};

const addBookingToFavourites = (id) => {
    const DBOpenRequest = setupIDB();
    DBOpenRequest.onsuccess = (dbOpenEvent) => {
        const db = DBOpenRequest.result;
        const transaction = db.transaction("favouriteShows", "readwrite");
        const objectStore = transaction.objectStore("favouriteShows");
        const now = new Date();
        const obj = {
            bookingId: id,
            numberOfVisits: 1,
            lastVisitDate: now.toUTCString()
        };
        const objectStoreRequest = objectStore.get(id);
        objectStoreRequest.onsuccess = (objectStoreEvent) => {
            const record = objectStoreRequest.result;
            if (record) {
                obj.numberOfVisits += record.numberOfVisits;
            }
            objectStore.put(obj);
        };
    };
};

const showFavouriteBookings = () => {
    const objects = [];
    const DBOpenRequest = setupIDB();
    DBOpenRequest.onerror = (dbOpenEvent) => {
        showErrorFavourites();
    };
    DBOpenRequest.onsuccess = (dbOpenEvent) => {
        const db = DBOpenRequest.result;
        const transaction = db.transaction("favouriteShows");
        const objectStore = transaction.objectStore("favouriteShows");
        const request = objectStore.openCursor();
        request.onsuccess = (objectStoreEvent) => {
            var obj, params;
            const cursor = objectStoreEvent.target.result;
            if (cursor) {
                objects.push(cursor.value);
                cursor.continue();
            } else {
                objects.sort((a, b) => {
                    return b.numberOfVisits - a.numberOfVisits;
                });
                params = {
                    ids: objects.slice(0, 9).map((obj) => {
                        return obj.bookingId;
                    })
                };
                $.post("bookings/favourites", params, appendFavourites, "html")
                        .fail(showErrorFavourites);
            }
        };
    };
};

$(() => {
    const regex = /^\/bookings\/([0-9]+)$/i;
    const match = window.location.pathname.match(regex);
    if (match && match.length === 2) {
        const bookingId = Number(match[1]);
        addBookingToFavourites(bookingId);
    } else if (window.location.pathname === "/bookings") {
        showFavouriteBookings();
    }
});
