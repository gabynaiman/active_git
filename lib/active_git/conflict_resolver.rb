module ActiveGit
  class ConflictResolver

    def self.resolve(base, ours, theirs)
      intersection = base.keys & ours.keys
      added = ours.keys - intersection
      removed = base.keys - intersection
      updated = intersection.select { |k| base[k] != ours[k] }

      theirs.dup.tap do |merge|
        removed.each { |k| merge.delete k }
        (added + updated).map.each { |k| merge[k] = ours[k] }
      end
    end

  end
end