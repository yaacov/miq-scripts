#!/usr/bin/env ruby

# Load Rails
ENV['RAILS_ENV'] = ARGV[0] || 'development'
DIR = File.dirname(__FILE__)
require DIR + '/../manageiq/config/environment'

# --------------------
# functions and consts
# --------------------

def push_metric (prov, timestamp, interval = "daily")
  prov.metric_rollups << MetricRollup.create(
    :capture_interval_name => interval,
    :timestamp => timestamp,
    :time_profile => TimeProfile.first,
    :cpu_usage_rate_average           => rand(100),
    :mem_usage_absolute_average       => rand(100),
    :derived_vm_numvcpus              => 4,
    :net_usage_rate_average           => rand(1000),
    :derived_memory_available         => 8192,
    :derived_memory_used              => rand(8192),
    :stat_containergroup_create_rate  => rand(100),
    :stat_containergroup_delete_rate  => rand(50))
end

def push_last_30_days(prov)
  (0 .. 30).each { |x|  push_metric(prov, x.days.ago, "daily") }
end

def push_last_24_hours(prov)
  (0 .. 24).each { |x|  push_metric(prov, x.hours.ago, "hourly") }
end

# --------------------
# push metric data
# --------------------

ExtManagementSystem.all.each do |prov|
  push_last_30_days(prov)
  push_last_24_hours(prov)
end
