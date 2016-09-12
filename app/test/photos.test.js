/*global describe, it, beforeEach, afterEach */
describe('Photo list', function () {

    var src = '../lib/photos',
        lib,
        requestMock,
        mockery = require('mockery'),
        sinon = require('sinon'),
        assert = require('assert');

    beforeEach(function () {
        requestMock = sinon.stub();
        mockery.enable({useCleanCache: true});
        mockery.registerMock('request', requestMock);
        mockery.registerAllowable('vm');
        mockery.registerAllowable(src, true);
        lib = require(src);
    });

    afterEach(function () {
        mockery.deregisterAll();
        mockery.disable();
    });

    it('lists photos correctly', function (done) {
        var data = {
            photos: {
                photo: [
                    {

                        "id": "12994967103",
                        "owner": "37115478@N05",
                        "secret": "9bfe7dc1aa",
                        "server": "7376",
                        "farm": 8,
                        "title": "Aerial View of Sky Tree and Tokyo Sprawl",
                        "ispublic": 1,
                        "isfriend": 0,
                        "isfamily": 0,
                        "url_n": "https://farm8.staticflickr.com/7376/12994967103_9bfe7dc1aa_n.jpg",
                        "height_n": 213,
                        "width_n": "320",
                        "description": {
                            "_content": "<b>Date:</b> 3/6/14 \n<b>Camera:</b> ILCE-7R\n<b>Exposure:</b> ¹⁄₆₄₀ sec at f/7.1, ISO 400\n<b>Lens:</b> 16-35mm F2.8 ZA SSM\n\n© 2014 Benjamin Torode - All Rights Reserved.\nNo Use Without Written Permission."
                        }
                    },
                    {

                        "id": "12987666173",
                        "owner": "76889078@N08",
                        "secret": "89b0fac45b",
                        "server": "3758",
                        "farm": 4,
                        "title": "",
                        "ispublic": 1,
                        "isfriend": 0,
                        "isfamily": 0,
                        "url_n": "https://farm4.staticflickr.com/3758/12987666173_89b0fac45b_n.jpg",
                        "height_n": "320",
                        "width_n": 214,
                        "description": {
                            "_content": "Taken in Fujiyoshida today with the Nikon D600 and AF-S Nikkor 24-85mm F3.5-4.5G ED VR"
                        }
                    }
                ]
            }
        };
        requestMock.yieldsAsync(null, {}, 'jsonFlickrApi(' + JSON.stringify(data) + ')');
        lib.list(function (err, data) {
            assert.ok(!err);
            assert.ok(Array.isArray(data.photos));
            assert.equal(requestMock.getCalls().length, 1);
            var requestArgs = requestMock.getCalls()[0].args[0];
            delete requestArgs.qs.api_key;
            delete requestArgs.qs.page;
            delete requestArgs.qs.per_page;
            assert.equal(requestArgs.uri, 'https://api.flickr.com/services/rest/');
            assert.equal(requestArgs.qs.method, 'flickr.photos.search');
            assert.equal(requestArgs.qs.tags, 'mount fuji');
            assert.equal(requestArgs.qs.format, 'json');
            done();
        });

    });
});
