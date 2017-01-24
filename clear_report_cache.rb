#!/usr/bin/env ruby

begin
  require './config/environment'
rescue LoadError
  DIR = File.dirname(__FILE__)
  require DIR + '/config/environment'
end

# delete metrics
Metric.delete_all
MetricRollup.delete_all

# delete reports cache
VimPerformanceOperatingRange.delete_all
MiqReportResult.delete_all
MiqReportResultDetail.delete_all
