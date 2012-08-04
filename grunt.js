module.exports = function(grunt) {
  var path = require('path');
  var fs = require('fs');

  grunt.initConfig({
    project : {
      coffee_src : 'src/coffee/**/*.coffee',
      site_src: ['site/**/*.html', 'site/**/*.css'],
      lib : ['src/lib/*.js', 'site/lib/*.js'],
      build_dir : "build/"
    },
    concat: {
      lib: {
        src:  '<config:project.lib>',
        dest: '<%= grunt.config("project.build_dir")'
                          + '+ "javascript/lib_all.js" %>'
      },
      all: {
        src: ['<%= grunt.config("project.build_dir")'
                          + '+ "javascript/lib_all.js" %>',
              '<%= grunt.config("project.build_dir")'
                          + '+ "javascript/lib_all.js" %>',
              '<%= grunt.config("project.build_dir")'
                          + '+ "javascript/utils.js" %>',
              '<%= grunt.config("project.build_dir")'
                          + '+ "javascript/mac.js" %>',
              '<%= grunt.config("project.build_dir")'
                          + '+ "javascript/mac_listener.js" %>',
              '<%= grunt.config("project.build_dir")'
                          + '+ "javascript/ram.js" %>',
              '<%= grunt.config("project.build_dir")'
                          + '+ "javascript/ram_listener.js" %>',
              '<%= grunt.config("project.build_dir")'
                          + '+ "javascript/rom.js" %>',
              '<%= grunt.config("project.build_dir")'
                          + '+ "javascript/rom_listener.js" %>',
              '<%= grunt.config("project.build_dir")'
                          + '+ "javascript/alu.js" %>',
              '<%= grunt.config("project.build_dir")'
                          + '+ "javascript/alu_listener.js" %>',
              '<%= grunt.config("project.build_dir")'
                          + '+ "javascript/cpu.js" %>',
              '<%= grunt.config("project.build_dir")'
                          + '+ "javascript/cpu_listener.js" %>',
              '<%= grunt.config("project.build_dir")'
                          + '+ "javascript/view.js" %>',
              '<%= grunt.config("project.build_dir")'
                          + '+ "javascript/main.js" %>'
              ],
        dest: '<%= grunt.config("project.build_dir")'
                          + '+ "javascript/kaffeemaschine_all.js" %>'
      }
    },
    min: {
      all: {
        src:  '<%= grunt.config("project.build_dir") '
                          + ' + "javascript/kaffeemaschine_all.js"%>',
        dest: '<%= grunt.config("project.build_dir") '
                          + ' + "javascript/kaffeemaschine_all.js.min"%>'
      }
    },
    watch: {
      files: '<config:project.coffee_src>',
      tasks: 'build:site:nomin'
    }
  });

grunt.registerTask('build:coffee', 'Compile coffeescript to javascript.',
  function() {
    var files = grunt.file.expandFiles(grunt.config("project.coffee_src"));
    var target_dir = grunt.config('project.build_dir') + 'javascript/';

    var coffee = require('coffee-script');
    files.forEach(function(filepath) {
        var target_name = path.basename(filepath).replace(/\.coffee$/, '.js');
        var target_path = target_dir + target_name;
        try {
          grunt.log.write("Compile " + filepath + " to "
                                        + target_path + "... ");
          var js = coffee.compile(grunt.file.read(filepath));
        } catch(e) {
          grunt.log.writeln("Error: " + e);
          throw e;
        }
        if (js) {
          grunt.file.write(target_path, js);
          grunt.log.writeln("Success");
        }
    });
  });

var build_site_requirements = 'clean:bundle build:coffee concat:lib concat:all';
grunt.registerTask('build-site', 'Generate html site.',
  function() {
    this.requires(build_site_requirements);

    var build_dir = grunt.config('project.build_dir');
    var files = grunt.file.expandFiles(grunt.config("project.site_src"));


    // copy html + css files
    var copy = function(src, dest) {
      grunt.log.write('Copy ' + src + ' to ' + dest + '... ');
      try {
        grunt.file.copy(src, dest);
        grunt.log.writeln('Success');
      } catch(e) {
        grunt.log.writeln('Error: ' + e);
        throw e;
      }
    }

    files.forEach(function(filepath) {
      var target_path = build_dir + filepath;
      copy(filepath, target_path);
    });

    var srcpath = build_dir + 'javascript/kaffeemaschine_all.js';
    if (this.flags.min) {
       srcpath += '.min';
    }

    copy(srcpath, build_dir + 'site/lib/kaffeemaschine_all.js');
});

grunt.registerTask('build:site', build_site_requirements + ' min build-site:min');
grunt.registerTask('build:site:nomin', build_site_requirements + ' build-site');

grunt.registerHelper('rm', function(target) {
  grunt.log.write('Delete ' + target + '... ');
  try {
    if(fs.statSync(target).isFile()) {
      fs.unlinkSync(target);
    } else {
      fs.rmdirSync(target);
    }
    grunt.log.writeln('Success');
  } catch(e) {
    grunt.log.writeln('Error: ' + e);
    throw e;
  }
});

grunt.registerTask('clean', 'Delete all temporary files.', function() {
  var build_dir = grunt.config('project.build_dir');

  var files = grunt.file.expandFiles(build_dir + '**/*');
  files.forEach(function(filepath) {
    grunt.task.helper('rm', filepath);
  });

  var dirs = grunt.file.expandDirs(build_dir + '**/*');
  dirs.reverse().forEach(function(dirpath) {
    grunt.task.helper('rm', dirpath);
  });

  grunt.task.helper('rm', build_dir);
});

grunt.registerTask('clean:bundle', 'Delete all bundle files.', function() {
  bundle_files = ['kaffeemaschine_all.js', 'kaffeemaschine_all.js.min'];
  bundle_files.forEach(function(bundle) {
    target = grunt.config('project.build_dir') + 'javascript/' + bundle;
    if (fs.existsSync(target)) {
      grunt.task.helper('rm', target);
    }
  });
});

  grunt.registerTask('default', 'build:site');
};
