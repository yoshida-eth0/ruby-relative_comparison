require 'set'


module HighLow

  CONFLICT_COMPARE = ->(a,b){ 0 }
  CONFLICT_SRICT_COMPARE = ->(a,b,routes){ routes.first&.metric || 0 }

  def self.merge(values_list, &block)
    Root.new(values_list).to_a(&block)
  end


  class Root
    attr_reader :nodes

    def initialize(values_list=[])
      @nodes = {}

      values_list.each {|values|
        regist_values(values)
      }
    end

    def regist_values(values)
      values.each_with_index {|value,i|
        lefts = values[0...i]
        rights = values[(i+1)..-1]
        regist_value(value, lefts, rights)
      }
    end

    def regist_value(value, lefts, rights)
      @nodes[value] ||= Node.new(value, self)

      lefts = lefts.reverse
      nonloop_lefts = [value]
      lefts.each{|v|
        break if nonloop_lefts.include?(v)
        nonloop_lefts << v
      }
      lefts = nonloop_lefts[1..-1]

      nonloop_rights = [value]
      rights.each{|v|
        break if nonloop_rights.include?(v)
        nonloop_rights << v
      }
      rights = nonloop_rights[1..-1]

      @nodes[value].lefts << lefts
      @nodes[value].rights << rights

    end

    def node(value)
      @nodes[value]
    end

    def exists?(value)
      @nodes.has_key?(value)
    end

    def fetch(value)
      if !exists?(value)
        raise NodeNotFound, "node not found: #{value}"
      end
      node(value)
    end

    def node_values
      @nodes.keys
    end

    def compare(src, dst, &block)
      if !block
        block = CONFLICT_COMPARE
      end

      fetch(src).compare(dst, &block)
    end

    def traceroutes(src, dst)
      fetch(src).traceroutes(dst)
    end

    def left_traceroutes(src, dst)
      fetch(src).left_traceroutes(dst)
    end

    def right_traceroutes(src, dst)
      fetch(src).right_traceroutes(dst)
    end

    def shortest_routes(src, dst)
      routes = traceroutes(src, dst).sort_by{|route| route.metric}
      min_metric = routes.first&.metric
      routes.select{|route| route.metric==min_metric}
    end

    def strict_compare(src, dst, &block)
      if !block
        block = CONFLICT_SRICT_COMPARE
      end

      routes = shortest_routes(src, dst)
      metrics = Set.new(routes.map(&:relative_metric))
      if metrics.length==1
        metrics.first
      else
        block.call(src, dst, routes)
      end
    end

    def to_a(&block)
      node_values.sort {|a,b|
        compare(a, b, &block)
      }
    end

    def has_branch?
      node_values.sort {|a,b|
        compare(a, b) {|a,b|
          return true
        }
      }
      false
    end

    def inspect
      # 参照が多くてppが見づらいので
      "<#HighLow::Root>"
    end
  end

  class Node
    attr_reader :value
    attr_accessor :metric
    attr_accessor :lefts
    attr_accessor :rights

    def initialize(value, root, metric: 1)
      @value = value
      @metric = metric
      @lefts = Neighbor.new
      @rights = Neighbor.new
      @root = root
    end

    def compare(dst, &block)
      return 0 if @value==dst
      return 1 if include_left?(dst)
      return -1 if include_right?(dst)

      block.call(@value, dst)
    end

    def include_left?(dst, recursions=Set.new)
      return false if recursions.include?(self)
      recursions = recursions + [self]

      return true if @lefts.exists?(dst)
      return true if @lefts.node_values.find{|v| @root.node(v).include_left?(dst, recursions)}
      false
    end

    def include_right?(dst, recursions=Set.new)
      return false if recursions.include?(self)
      recursions = recursions + [self]

      return true if @rights.exists?(dst)
      return true if @rights.node_values.find{|v| @root.node(v).include_right?(dst, recursions)}
      false
    end

    def next_lefts
      @lefts.nearests.map{|value| @root.node(value)}
    end

    def next_rights
      @rights.nearests.map{|value| @root.node(value)}
    end

    def traceroutes(dst)
      left_traceroutes(dst) + right_traceroute(dst)
    end

    def left_traceroutes(dst, route=TraceRoute.new_left)
      return [] if route.include?(self)
      route = route.hop(self)

      return [route] if @value==dst

      next_lefts.map {|node|
        node.left_traceroutes(dst, route)
      }.flatten(1)
    end

    def right_traceroutes(dst, route=TraceRoute.new_right)
      return [] if route.include?(self)
      route = route.hop(self)

      return [route] if @value==dst

      next_rights.map {|node|
        node.right_traceroutes(dst, route)
      }.flatten(1)
    end
  end

  class Neighbor
    def initialize
      @nodes = {}
      @nears = Set.new
    end

    def <<(values)
      values.each_with_index {|value,i|
        @nodes[value] ||= NeighborNode.new(value, self)
        @nodes[value].lefts += values[0...i]
        @nodes[value].rights += values[(i+1)..-1]
      }
      if 0<values.length
        @nears << values.first
      end
    end

    def node(value)
      @nodes[value]
    end

    def exists?(value)
      @nodes.has_key?(value)
    end

    def fetch(value)
      if !exists?(value)
        raise NodeNotFound, "node not found: #{value}"
      end
      node(value)
    end

    def node_values
      @nodes.keys
    end

    def compare(src, dst, &block)
      if !block
        block = CONFLICT_COMPARE
      end

      fetch(src).compare(dst, &block)
    end

    def nearests(&block)
      near = @nears.sort {|a,b|
        compare(a, b)
      }.first

      @nears.select{|value|
        compare(value, near)==0
      }
    end
  end

  class NeighborNode
    attr_reader :value
    attr_accessor :lefts
    attr_accessor :rights

    def initialize(value, neighbor)
      @value = value
      @lefts = Set.new
      @rights = Set.new
      @neighbor = neighbor
    end

    def compare(dst, &block)
      return 0 if @value==dst
      return 1 if include_left?(dst)
      return -1 if include_right?(dst)

      block.call(@value, dst)
    end

    def include_left?(dst, recursions=Set.new)
      return false if recursions.include?(self)
      recursions = recursions + [self]

      return true if @lefts.include?(dst)
      return true if @lefts.find{|v| @neighbor.node(v).include_left?(dst, recursions)}
      false
    end

    def include_right?(dst, recursions=Set.new)
      return false if recursions.include?(self)
      recursions = recursions + [self]

      return true if @rights.include?(dst)
      return true if @rights.find{|v| @neighbor.node(v).include_right?(dst, recursions)}
      false
    end
  end

  class TraceRoute
    include Enumerable

    LEFT = :left
    RIGHT = :right

    attr_reader :direction

    def initialize(direction, nodes=[])
      @direction = direction
      @nodes = nodes
    end

    def each(&block)
      @nodes.each(&block)
    end

    def hop(a)
      self.class.new(@direction, @nodes + [a])
    end

    def metric
      @nodes[1..-1].map(&:metric).sum
    end

    def relative_metric
      sign = @direction==LEFT ? 1 : -1
      metric * sign
    end

    def self.new_left
      new(LEFT)
    end

    def self.new_right
      new(RIGHT)
    end
  end

  class Error < StandardError
  end

  class NodeNotFound < Error
  end
end
