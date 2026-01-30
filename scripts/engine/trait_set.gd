class_name TraitSet

var traits: Array[Trait]
var traits_by_tags: Dictionary[String, Array]

func _init(_traits: Array[Trait]):
  self.traits = _traits

  self.traits_by_tags = {}
  for t in self.traits:
    for tag in t.tags():
      if tag not in self.traits_by_tags:
        self.traits_by_tags[tag] = []
      self.traits_by_tags[tag].append(t)

## Gets all traits in the set that match the given tag
## Excludes 
func get_traits_by_tag(tag: String) -> Array[Trait]:
  var ret: Array[Trait] = []
  ret.assign(self.traits_by_tags.get(tag, []))
  return ret
  

func calc_score() -> int:
  var score = 0
  for t in self.traits:
    score += t.calc_score(self)
  return score
