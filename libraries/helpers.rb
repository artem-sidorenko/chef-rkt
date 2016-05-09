#
# License: Apache 2.0
#
# Copyright: 2016 Artem Sidorenko and contributors.
#
# See the COPYRIGHT file at the top-level directory of this distribution
# and at https://gitlab.com/artem-sidorenko/chef-rkt/blob/master/COPYRIGHT
#

# Some helper functions

# Run rkt subcommand and return its stdout
# Raise an exception in case of errors
def rkt_run_cmd(subcommand, args, log_action)
  cmd = "rkt #{subcommand} " + args.join(' ')
  run_cmd = Mixlib::ShellOut.new(cmd).run_command
  if run_cmd.error?
    raise "#{new_resource} action #{log_action} failed,
           Following command line was called: #{cmd}

           Stdout:

           #{run_cmd.stdout}

           Stderr:

           #{run_cmd.stderr}"
  end
  run_cmd.stdout
end

# Return image id (hash) from given image name
# returns nil if image is not present
def rkt_image_name_to_id(image_name)
  output = rkt_run_cmd('image list', ['--no-legend=true', '--fields=id,name'], 'image check')
  images = {}
  output.split("\n").each do |line|
    values = line.split
    images[values[1]] = values[0]
  end
  images[image_name]
end
