require 'minitest/autorun'
require 'ruby2js/filter/angularrb'
require 'ruby2js/filter/angular-route'
require 'ruby2js/filter/angular-resource'

describe Ruby2JS::Filter::AngularRB do
  
  def to_js( string)
    Ruby2JS.convert(string, filters: [Ruby2JS::Filter::AngularRB,
      Ruby2JS::Filter::AngularRoute, Ruby2JS::Filter::AngularResource])
  end
  
  describe 'module' do
    it "should convert empty modules" do
      to_js( 'module Angular::X; end' ).
        must_equal 'angular.module("X", [])'
    end

    it "should convert modules with a use statement" do
      ruby = <<-RUBY
        module Angular::PhonecatApp 
          use :PhonecatFilters
        end
      RUBY

      js = <<-JS.gsub!(/^ {8}/, '').chomp
        angular.module("PhonecatApp", ["PhonecatFilters"])
      JS

      to_js( ruby ).must_equal js
    end
  end
  
  describe 'controllers' do
    it "should convert apps with a controller" do
      ruby = <<-RUBY
        module Angular::PhonecatApp 
          controller :PhoneListCtrl do 
            $scope.orderProp = 'age'
          end
        end
      RUBY

      js = <<-JS.gsub!(/^ {8}/, '').chomp
        angular.module("PhonecatApp", []).controller("PhoneListCtrl", function($scope) {
          $scope.orderProp = "age"
        })
      JS

      to_js( ruby ).must_equal js
    end
  end
  
  describe 'filter' do
    it "should convert apps with a filter" do
      ruby = <<-RUBY
        module Angular::PhonecatApp 
          filter :pnl do |input|
            if input < 0
              "loss"
            else
              "profit"
            end
          end
        end
      RUBY

      js = <<-JS.gsub!(/^ {8}/, '').chomp
        angular.module("PhonecatApp", []).filter("pnl", function() {
          return function(input) {
            return (input < 0 ? "loss" : "profit")
          }
        })
      JS

      to_js( ruby ).must_equal js
    end
  end
  
  describe 'route' do
    it "should convert apps with a route" do
      ruby = <<-RUBY
        module Angular::PhonecatApp 
          case $routeProvider
          when '/phones'
            controller = :PhoneListCtrl
          else
            redirectTo '/phones'
          end
        end
      RUBY

      js = <<-JS.gsub!(/^ {8}/, '').chomp
        angular.module("PhonecatApp", ["ngRoute"]).config([
          "$routeProvider",

          function($routeProvider) {
            $routeProvider.when("/phones", {controller: "PhoneListCtrl"}).otherwise({redirectTo: "/phones"})
          }
        ])
      JS

      to_js( ruby ).must_equal js
    end
  end

  describe 'factory' do
    it "should convert apps with a factory" do
      ruby = <<-RUBY
        module Angular::Service
          factory :Phone do
            return $resource.new 'phone/:phoneId.json'
          end
        end
      RUBY

      js = <<-JS.gsub!(/^ {8}/, '').chomp
        angular.module("Service", ["ngResource"]).factory("Phone", [
          "$resource",

          function($resource) {
            return $resource("phone/:phoneId.json")
          }
        ])
      JS

      to_js( ruby ).must_equal js
    end

    it "should convert apps with a factory defined as a class" do
      ruby = <<-RUBY
        module Angular::Service
          class Phone
            def self.name
              "XYZZY"
            end
          end
        end
      RUBY

      js = "(function() {\n#{<<-JS.gsub!(/^ {6}/, '')}})()"
        const Service = angular.module("Service", []);
        function Phone() {};

        Phone.name = function() {
          "XYZZY"
        };

        Service.factory("Phone", [function() {
          return Phone
        }])
      JS

      to_js( ruby ).must_equal js
    end
  end

  describe 'controllers' do
    it "should convert apps with a directive" do
      ruby = <<-RUBY
        module Angular::PhonecatApp 
          directive :my_signature do 
            return {template: '--signature'}
          end
        end
      RUBY

      js = <<-JS.gsub!(/^ {8}/, '').chomp
        angular.module("PhonecatApp", []).directive("my_signature", function() {
          return {template: "--signature"}
        })
      JS

      to_js( ruby ).must_equal js
    end
  end

  describe Ruby2JS::Filter::DEFAULTS do
    it "should include AngularRB" do
      Ruby2JS::Filter::DEFAULTS.must_include Ruby2JS::Filter::AngularRB
    end

    it "should include AngularRoute" do
      Ruby2JS::Filter::DEFAULTS.must_include Ruby2JS::Filter::AngularRoute
    end

    it "should include AngularResource" do
      Ruby2JS::Filter::DEFAULTS.must_include Ruby2JS::Filter::AngularResource
    end
  end
end
