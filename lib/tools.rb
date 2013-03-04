
def projects_regex
  @projects_regex ||= $versions.keys.sort{|a,b| b.length <=> a.length}.map{|j| j.to_s.gsub(/(\W)/){'\\'+$1}}.join("|")
end

def include_latest?(project)
  $versions_data ||= YAML::load(File.open('data/versions.yml'))
  $versions_data['currents'][project] == $versions[project.to_sym]
end
