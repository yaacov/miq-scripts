#!/usr/bin/env ruby

# Load Rails
ENV['RAILS_ENV'] = ARGV[0] || 'development'
DIR = File.dirname(__FILE__) 
require DIR + '/../manageiq/config/environment'

# create and run worker, metrics collector
#-----------------------------------------

#worker_class = ManageIQ::Providers::Kubernetes::ContainerManager::EventCatcher
worker_class = ManageIQ::Providers::Kubernetes::ContainerManager::MetricsCollectorWorker
runner_class = worker_class::Runner
worker = worker_class.create_worker_record
ems_id = "3"
runner_cfg = {:guid => worker.guid, :ems_id => ems_id}
runner = runner_class.new(runner_cfg)

# print worker results
#---------------------

runner.start

pp({last_heartbeat: MiqWorker.last.last_heartbeat,
    pid: MiqWorker.last.pid,
    queue_name: MiqWorker.last.queue_name,
    type: MiqWorker.last.type,
    percent_memory: MiqWorker.last.percent_memory,
    percent_cpu: MiqWorker.last.percent_cpu,
    cpu_time: MiqWorker.last.cpu_time,
    os_priority: MiqWorker.last.os_priority,
    memory_usage: MiqWorker.last.memory_usage,
    memory_size: MiqWorker.last.memory_size})

