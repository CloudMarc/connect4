require 'daemons'

options = {
  :log_output => false,
  :backtrace => true,
  :multiple => true
}
Daemons.run('monteCarloLearn.rb', options)
