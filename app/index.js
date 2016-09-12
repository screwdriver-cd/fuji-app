/*jslint nomen: true */
var express = require('express'),
    app,
    photos = require('./lib/photos'),
    exphbs = require('express3-handlebars');

process.chdir(__dirname);
app = express();
app.engine('handlebars', exphbs({ layout: false }));
app.set('view engine', 'handlebars');
app.use(app.router);
app.use(express['static'](__dirname + '/public'));

app.get('/', function (req, res, next) {
    var json = req.query.format === 'json',
        view = req.query.view === 'simple' ? 'index' : 'photos',
        page = req.query.page || 1;

    photos.list(page, function (err, data) {
        if (err) { return next(err); }
        var locals = {
            tag: data.tag,
            photos: data.photos
        };
        if (json) {
            res.json(locals);
        } else {
            res.locals(locals);
            res.render(view);
        }
    });
});

module.exports = app;
app.listen(7000);
