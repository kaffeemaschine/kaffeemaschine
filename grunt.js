module.exports = function(grunt) {
  var path = require('path');
  var fs = require('fs');

  grunt.initConfig({
    project: {
      coffee_src: 'src/**/*.coffee',
      site_src: ['site/**/*.html', 'site/**/*.css'],
      test_src: ['test/**/*.coffee'],
      lib: ['src/lib/*.js', 'site/lib/jquery.js', 'site/lib/bootstrap.js'],
      build_dir: "build/"
    },
    concat: {
      lib: {
        src:  '<config:project.lib>',
        dest: '<%= grunt.config("project.build_dir")'
                          + '+ "javascript/lib_all.js" %>'
      },
      main_earlyfiles: {
        src: ['<%= grunt.config("project.build_dir")'
                          + '+ "javascript/config/**/*.js" %>',
              '<%= grunt.config("project.build_dir")'
                          + '+ "javascript/coffee/util/**/*.js" %>',
              '<%= grunt.config("project.build_dir")'
                          + '+ "javascript/coffee/listeners/**/*.js" %>',
              '<%= grunt.config("project.build_dir")'
                          + '+ "javascript/coffee/models/**/*.js" %>',
              ],
        dest: '<%= grunt.config("project.build_dir")'
                          + '+ "javascript/main_earlyfiles_all.js" %>'
      },
      main_latefiles: {
        src: ['<%= grunt.config("project.build_dir")'
                          + '+ "javascript/coffee/controllers/**/*.js" %>',
              '<%= grunt.config("project.build_dir")'
                          + '+ "javascript/coffee/ui/**/*.js" %>',
              '<%= grunt.config("project.build_dir")'
                          + '+ "javascript/coffee/main.js" %>',
              ],
        dest: '<%= grunt.config("project.build_dir")'
                          + '+ "javascript/main_latefiles_all.js" %>'
      },
      all: {
        src: ['<%= grunt.config("project.build_dir")'
                          + '+ "javascript/lib_all.js" %>',
              '<%= grunt.config("project.build_dir")'
                          + '+ "javascript/main_earlyfiles_all.js" %>',
              '<%= grunt.config("project.build_dir")'
                          + '+ "javascript/main_latefiles_all.js" %>',
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
      files: ['src/**/*', 'site/**/*'],
      tasks: 'build:nomin:nolint'
    },
  });

  grunt.registerTask('bundle', 'concat:lib concat:main_earlyfiles concat:main_latefiles concat:all');

  grunt.registerTask('compile', 'Compile coffee-script to javascript.',
    function() {
      var files = grunt.file.expandFiles(grunt.config("project.coffee_src"));
      var target_dir = grunt.config('project.build_dir') + 'javascript/';

      var coffee = require('coffee-script');
      files.forEach(function(filepath) {
          // strip src from each filepath
          var relative_path = filepath.replace(/^src\//,'');
          // replace extension .coffee with .js
          relative_path = relative_path.replace(/\.coffee$/, '.js');

          var target_path = target_dir + relative_path;
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

  grunt.registerTask('build', 'Build project', function() {
    // delete bundle files since they have to be regenerated
    grunt.task.run('clean:bundle');
    // compile coffee-script
    grunt.task.run('compile');
    // bundle everything
    grunt.task.run('bundle');
    // minification disabled?
    if (this.flags.nomin == null) { grunt.task.run('min') };
    // build site
    grunt.task.run('_build:site');
    // coffeelint disabled?
    if (this.flags.nolint == null) { grunt.task.run('lint'); }
  });

  grunt.registerTask('_build:site', 'Generate html site.',
    function() {
      this.requires('clean:bundle compile bundle');

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

  grunt.registerTask('lint', 'Execute coffeelint on all src- and test-files.',
    function() {
      // node.js child_process is async, so this task needs to be async
      var done = this.async();

      var srcfiles = grunt.file.expandFiles(grunt.config("project.coffee_src"));
      var testfiles = grunt.file.expandFiles(grunt.config("project.test_src"));
      var allfiles = srcfiles.concat(testfiles).join(" ");

      child = require('child_process');
      child.exec('coffeelint ' + allfiles, function(error, stdout, stderr) {
        process.stdout.write(stdout);
        process.stderr.write(stderr);
        (error == null) ? done() : done(false);
      });
  });

  grunt.registerHelper('rm', function(target) {
    grunt.log.write('Delete ' + target + '... ');
    try {
      if (fs.existsSync(target) === false) {
        grunt.log.writeln('Does not exist');
        return;
      } else if (fs.statSync(target).isFile()) {
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

  grunt.registerTask('clean', 'Delete temporary files.', function() {
    var build_dir = grunt.config('project.build_dir');
    var targets;

    if (this.flags.bundle) {
      // delete only bundle files
      var prefix = grunt.config('project.build_dir') + 'javascript/';
      targets = [ prefix + 'kaffeemaschine_all.js',
                prefix  + 'kaffeemaschine_all.js.min'
              ]
    } else {
      // delete all build files
      var files = grunt.file.expandFiles(build_dir + '**/*');
      var dirs = grunt.file.expandDirs(build_dir + '**/*').reverse();
      targets = files.concat(dirs);
    }

    targets.forEach(function(target) {
      grunt.task.helper('rm', target)
    });
  });

  grunt.registerTask('default', 'build');
};
