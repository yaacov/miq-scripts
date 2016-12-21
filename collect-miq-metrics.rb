#!/usr/bin/env ruby

begin
  require './config/environment'
rescue LoadError
  DIR = File.dirname(__FILE__)
  require DIR + '/config/environment'
end

# remove old data
#Metric.destroy_all
#MetricRollup.destroy_all

NUM_OF_DAYS = 1

# authenticate and refresh all Providers
ManageIQ::Providers::ContainerManager.all.each { |n| n.authentication_check && EmsRefresh.refresh(n) }

# get realtime data (we only know how to collect data about containers, nodes and pods)
Container.all.each { |n| n.perf_capture('realtime', start_time = NUM_OF_DAYS.days.ago, end_time = 0.days.ago) }
ContainerNode.all.each { |n| n.perf_capture('realtime', start_time = NUM_OF_DAYS.days.ago, end_time = 0.days.ago) }
ContainerGroup.all.each { |n| n.perf_capture('realtime', start_time = NUM_OF_DAYS.days.ago, end_time = 0.days.ago) }

(0..(NUM_OF_DAYS * 24)).each { |h| ContainerGroup.all.each { |n| n.perf_rollup(h.hour.ago.utc.beginning_of_hour.iso8601, "hourly") } }
(0..NUM_OF_DAYS).each { |d| ContainerGroup.all.each { |n| n.perf_rollup(d.days.ago.utc.beginning_of_day.iso8601, "daily", TimeProfile.first) } }

(0..(NUM_OF_DAYS * 24)).each { |h| ContainerNode.all.each { |n| n.perf_rollup(h.hour.ago.utc.beginning_of_hour.iso8601, "hourly") } }
(0..NUM_OF_DAYS).each { |d| ContainerNode.all.each { |n| n.perf_rollup(d.days.ago.utc.beginning_of_day.iso8601, "daily", TimeProfile.first) } }

(0..(NUM_OF_DAYS * 24)).each { |h| ManageIQ::Providers::ContainerManager.all.each { |n| n.perf_rollup(h.hour.ago.utc.beginning_of_hour.iso8601, "hourly") } }
(0..NUM_OF_DAYS).each { |d| ManageIQ::Providers::ContainerManager.all.each { |n| n.perf_rollup(d.days.ago.utc.beginning_of_day.iso8601, "daily", TimeProfile.first) } }
