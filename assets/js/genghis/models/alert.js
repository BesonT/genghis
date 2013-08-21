define(['backbone', 'genghis/models'], function(Backbone, Models) {

    return Models.Alert = Backbone.Model.extend({
        defaults: {
            level: 'warning',
            block: false
        },

        block: function() {
            return !!this.get('block');
        },

        level: function() {
            var level = this.get('level');

            return (level === 'error') ? 'danger' : level;
        },

        msg: function() {
            return this.get('msg');
        }
    });
});