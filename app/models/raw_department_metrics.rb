class RawDepartmentMetrics < RawMetrics
  def initialize(root, time_period:)
    @root = root
    @time_period = time_period
  end

  attr_reader :root, :time_period

private

  def query(cls, key)
    service_ids = Hash[@root.services.map { |s|
      [s.natural_key, [s.name, s.delivery_organisation.name]]
    }]

    metrics = cls
      .where('department_code = ?', @root.natural_key)
      .where('starts_on >= ? AND ends_on <= ?', time_period.starts_on, time_period.ends_on)
      .order('starts_on')
      .group_by { |m| [m.service_code, m.delivery_organisation_code, m.starts_on] }

    results = Hash.new { |h, k| h[k] = [] }

    metrics.each { |(service_code, _, date), list|
      merged_metric = list.inject({}) { |memo, metric|
        keyname = clean_keyname(metric, key)
        memo[keyname] = metric["quantity"]
        memo
      }

      merged_metric["department"] = @root.name
      merged_metric["agency"] = service_ids[service_code][1]
      merged_metric["service"] = service_ids[service_code][0]

      results[date] << merged_metric
    }
    results
  end
end
