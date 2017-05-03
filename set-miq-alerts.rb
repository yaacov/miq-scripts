#!/usr/bin/env ruby
require File.join(Dir.pwd, 'config/environment')

ALERT_UUID="17ac4258-cd1e-11e6-914b-024234304b62"
MiqAlert.where(:guid => ALERT_UUID).destroy_all # will destroy statuses and action(?) too
ma = MiqAlert.create!(guid: ALERT_UUID, description: "All hawkular", options: {:notifications=>{:delay_next_evaluation=>600, :evm_event=>{}, :automate=>{:event_name=>"Oh no, an alert"}}}, db: "ContainerNode", expression: {:eval_method=>"hwk_generic", :mode=>"internal", :options=>{}})
# create new MAS based on the existing ones

ExtManagementSystem.all.each do |ext|
  mas = MiqAlertStatus.create!(
    :miq_alert_id  => ma.id,
    :resource_id   => ext.container_nodes.first.id,
    :resource_type => 'ContainerNode',
    :evaluated_on  => Time.zone.now,
    :severity      => "error",
    :ems_id        => ext.id
  )

  mas2 = MiqAlertStatus.create!(
    :miq_alert_id  => ma.id,
    :resource_id   => ext.container_nodes.second.id,
    :resource_type => 'ContainerNode',
    :evaluated_on  => Time.zone.now,
    :severity      => "warning",
    :ems_id        => ext.id
  )

  mas3 = MiqAlertStatus.create!(
    :miq_alert_id  => ma.id,
    :resource_id   => ext.container_nodes.second.id,
    :resource_type => 'ContainerNode',
    :evaluated_on  => Time.zone.now,
    :severity      => "warning",
    :ems_id        => ext.id
  )

  MiqAlertStatusAction.create!(
    action_type: 'comment', user: User.first, comment: "hello there!", miq_alert_status_id: mas.id
  )

  sleep 1

  MiqAlertStatusAction.create!(
    action_type: 'assign', user: User.first, assignee: User.first, miq_alert_status_id: mas.id
  )

  sleep 1

  MiqAlertStatusAction.create!(
    action_type: 'acknowledge', user: User.first, miq_alert_status_id: mas.id
  )

end

