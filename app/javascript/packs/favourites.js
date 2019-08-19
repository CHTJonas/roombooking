import $ from "jquery";

// Favourite bookings are stored in an indexed database locally in the user's
// browser. This provides a level of isolation for privacy reasons.
var addBookingToFavourites, appendFavourites, clearFavourites, setupIDB, showErrorFavourites, showFavouriteBookings;

clearFavourites = () => {
  $('#favourite-bookings-spinner').replaceWith('<p class="mt-4 my-3">None!</p>');
};

showErrorFavourites = () => {
  $('#favourite-bookings-spinner').replaceWith('<p class="mt-4 my-3">An error occurred retrieving favourite bookings!</p>');
};

appendFavourites = (data) => {
  if (data) {
    $('#favourite-bookings-container').replaceWith(data);
  } else {
    clearFavourites();
  }
};

setupIDB = () => {
  var DBOpenRequest;
  DBOpenRequest = indexedDB.open("roombooking", 1);
  DBOpenRequest.onupgradeneeded = (event) => {
    var db, objectStore;
    db = event.target.result;
    db.onerror = (e) => {
      console.error(e);
      throw "An error occurred";
    };
    objectStore = db.createObjectStore("favouriteShows", {
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

addBookingToFavourites = (id) => {
  var DBOpenRequest;
  DBOpenRequest = setupIDB();
  return DBOpenRequest.onsuccess = (event) => {
    var db, now, obj, objectStore, objectStoreRequest, transaction;
    db = DBOpenRequest.result;
    transaction = db.transaction("favouriteShows", "readwrite");
    objectStore = transaction.objectStore("favouriteShows");
    now = new Date();
    obj = {
      bookingId: id,
      numberOfVisits: 1,
      lastVisitDate: now.toUTCString()
    };
    objectStoreRequest = objectStore.get(id);
    return objectStoreRequest.onsuccess = (event) => {
      var record;
      record = objectStoreRequest.result;
      if (record) {
        obj.numberOfVisits += record.numberOfVisits;
      }
      return objectStore.put(obj);
    };
  };
};

showFavouriteBookings = () => {
  var DBOpenRequest, objs;
  objs = [];
  DBOpenRequest = setupIDB();
  DBOpenRequest.onerror = (event) => {
    showErrorFavourites();
  };
  return DBOpenRequest.onsuccess = (event) => {
    var db, objectStore, request, transaction;
    db = DBOpenRequest.result;
    transaction = db.transaction("favouriteShows");
    objectStore = transaction.objectStore("favouriteShows");
    request = objectStore.openCursor();
    return request.onsuccess = (event) => {
      var cursor, obj, params;
      cursor = event.target.result;
      if (cursor) {
        obj = cursor.value;
        objs.push(obj);
        return cursor.continue();
      } else {
        objs.sort(function(a, b) {
          return b.numberOfVisits - a.numberOfVisits;
        });
        params = {
          ids: objs.slice(0, 9).map(function(obj) {
            return obj.bookingId;
          })
        };
        return $.post("bookings/favourites", params, appendFavourites, "html");
      }
    };
  };
};

$(() => {
  var bookingId, match, regex;
  regex = /^\/bookings\/([0-9]+)$/i;
  match = window.location.pathname.match(regex);
  if (match && match.length === 2) {
    bookingId = Number(match[1]);
    addBookingToFavourites(bookingId);
  } else if (window.location.pathname === "/bookings") {
    showFavouriteBookings();
  }
});
