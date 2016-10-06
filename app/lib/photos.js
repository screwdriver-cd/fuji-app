/*jslint nomen: true */
var request = require('request'),
    vm = require('vm'),
    token = '46081a02eaa5123f97df07d28660db30',
    tag = 'golden gate bridge';

function jsonFlickrApi(data) {
    return data.photos.photo;
}

module.exports = {
    list: function (page, callback) {

        if (!callback && typeof page === 'function') {
            callback = page;
            page = 1;
        }
        var extras = ['s', 'q', 'm', 'n', 'z', 'c', 'l', 'o'].map(function (ch) {
            return 'url_' + ch;
        }).join(",");

        console.log('Getting photos for keyword [' + tag + '] set [' + page + ']');
        request({
            uri: 'https://api.flickr.com/services/rest/',
            qs: {
                api_key: token,
                method: 'flickr.photos.search',
                tags: tag,
                extras: extras + ',description',
                format: 'json',
                per_page: 10,
                page: page
            }
        }, function (err, response, data) {
            if (err) {
                console.log('Error retrieving photos: ' + err.message + '\n' + err.stack);
                return callback(err);
            }
            console.log('Found photos to return');
            var sandbox = {
                jsonFlickrApi: jsonFlickrApi
            };
            try {
                data = vm.runInNewContext(data, sandbox, __filename);
            } catch (ex) {
                return callback(ex);
            }
            data.forEach(function (photo) {
                photo.title = photo.title || 'Untitled';
            });
            return callback(err, { tag: tag, photos: data });
        });
    }
};
