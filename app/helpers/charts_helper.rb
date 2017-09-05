module ChartsHelper

  # We use https://github.com/ankane/chartkick for rails and https://github.com/ankane/vue-chartkick
  # together. Thus, we need to override the helpers a little.
  #
  def line_chart(data, options = {})
    data_options = if data.respond_to? :chart_json
      {':data' => data.chart_json}
    else
      {data: data}
    end
    content_tag 'line-chart', '', options.merge(data_options)
  end

end