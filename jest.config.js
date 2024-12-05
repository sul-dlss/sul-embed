const util = require('util')
const exec = util.promisify(require('child_process').exec)

module.exports = async () => {
  console.log('Getting asset pipeline lookup path from Rails')
  const { stdout, stderr } = await exec('bundle exec rake asset_paths')
  if (stderr) {
    console.error(stderr)
  }
  const paths = stdout.trim().split('\n')
  return {
    moduleDirectories: [
      'node_modules',
      ...paths,
    ],
    rootDir: './',
    setupFiles: [
      '<rootDir>/setupJest.js',
    ],
    testMatch: [
      '<rootDir>/spec/javascripts/common_viewer/**/*.js',
      '<rootDir>/spec/javascripts/geo/**/*.js',
    ],
    testEnvironment: 'jsdom',
  }
}
