@block @block_massaction @block_massaction_mimo
Feature: Check if mass actions work properly in format_mimo

  Background:
    Given I installed course format "mimo"
    And the following "users" exist:
      | username | firstname | lastname | email                |
      | teacher1 | Mr        | Teacher  | teacher1@example.com |
    And the following "format_mimo > tags" exist:
      | name     | activitytype1 | activitytype2 |
      | Reading  | page          | book          |
      | Practice | assign        | quiz          |
    And the following "format_mimo > courses" exist:
      | fullname      | shortname | format | enablemultisection | numsections |
      | Test course   | TC        | mimo   | 0                  | 1           |
      | Test course 2 | TC2       | mimo   | 1                  | 3           |
    And the following "course enrolments" exist:
      | user     | course | role           |
      | teacher1 | TC     | editingteacher |
      | teacher1 | TC2    | editingteacher |
    And the following "format_mimo > activities" exist:
      | activity | name           | intro                 | course | section | tag      |
      | page     | Test Activity1 | Test page description | TC     | 1       | Reading  |
      | assign   | Test Activity2 | Test assign desc      | TC     | 1       | Practice |
      | page     | Test Activity3 | Test page description | TC2    | 1       | Reading  |
      | assign   | Test Activity4 | Test assign desc      | TC2    | 1       | Practice |
      | page     | Test Activity5 | Test page description | TC2    | 2       | Reading  |
    And the following config values are set as admin:
      | config                  | value | plugin           |
      | applicablecourseformats | mimo  | block_massaction |

  @javascript
  Scenario: Check if checkboxes and the section selector work in single-section mode
    When I log in as "teacher1"
    And I am on "Test course" course homepage with editing mode on
    And I add the "Mass Actions" block
    And I click on "Enable bulk editing" "button"
    Then "#block-massaction-control-section-list-select-option-0" "css_element" should not exist
    And the "disabled" attribute of "#block-massaction-control-section-list-select-option-1" "css_element" should not be set
    When I set the field "block-massaction-control-section-list-select" to "1"
    Then the field "Test Activity1" matches value "1"
    And the field "Test Activity2" matches value "1"
    And I should see "2 selected" in the "sticky-footer" "region"
    When I click on "Deselect all" "button" in the "Mass Actions" "block"
    Then the field "Test Activity1" matches value ""
    And the field "Test Activity2" matches value ""
    When I click on "Select all" "button" in the "Mass Actions" "block"
    Then the field "Test Activity1" matches value "1"
    And the field "Test Activity2" matches value "1"
    And I should see "2 selected" in the "sticky-footer" "region"

  @javascript
  Scenario: Check if indentation is not offered in mimo format
    When I log in as "teacher1"
    And I am on "Test course" course homepage with editing mode on
    And I add the "Mass Actions" block
    Then "Indent (move right)" "button" should not exist in the "Mass Actions" "block"
    And "Outdent (move left)" "button" should not exist in the "Mass Actions" "block"

  @javascript
  Scenario: Check if mass action 'duplicate' works in mimo format
    When I log in as "teacher1"
    And I am on "Test course" course homepage with editing mode on
    And I add the "Mass Actions" block
    And I click on "Enable bulk editing" "button"
    And I click on "Test Activity1" "checkbox"
    And I click on "Test Activity2" "checkbox"
    And I click on "Duplicate" "button" in the "Mass Actions" "block"
    Then I should see "Test Activity1 (copy)" in the ".mimo-activities" "css_element"
    And I should see "Test Activity2 (copy)" in the ".mimo-activities" "css_element"

  @javascript
  Scenario: Check if mass action 'delete' works in mimo format
    When I log in as "teacher1"
    And I am on "Test course" course homepage with editing mode on
    And I add the "Mass Actions" block
    And I click on "Enable bulk editing" "button"
    And I click on "Test Activity1" "checkbox"
    And I click on "Delete" "button" in the "Mass Actions" "block"
    And I click on "Delete" "button"
    Then I should not see "Test Activity1"
    And I should see "Test Activity2"

  @javascript
  Scenario: Check if only the displayed wall is selectable in multi-section mode
    When I log in as "teacher1"
    And I am on "Test course 2" course homepage
    And I click on "Section 1" "link" in the ".mimo-overview-grid" "css_element"
    And I turn editing mode on
    And I add the "Mass Actions" block
    And I click on "Enable bulk editing" "button"
    Then "#block-massaction-control-section-list-select-option-0" "css_element" should not exist
    And the "disabled" attribute of "#block-massaction-control-section-list-select-option-1" "css_element" should not be set
    And the "disabled" attribute of "#block-massaction-control-section-list-select-option-2" "css_element" should be set
    And the "disabled" attribute of "#block-massaction-control-section-list-select-option-3" "css_element" should be set
    When I set the field "block-massaction-control-section-list-select" to "1"
    Then the field "Test Activity3" matches value "1"
    And the field "Test Activity4" matches value "1"
    And I should see "2 selected" in the "sticky-footer" "region"

  @javascript
  Scenario: Check if mass action 'move to section' works between walls in multi-section mode
    When I log in as "teacher1"
    And I am on "Test course 2" course homepage
    And I click on "Section 1" "link" in the ".mimo-overview-grid" "css_element"
    And I turn editing mode on
    And I add the "Mass Actions" block
    And I click on "Enable bulk editing" "button"
    And I click on "Test Activity3" "checkbox"
    And I set the field "target_section_moving" in the "Mass Actions" "block" to "2"
    And I click on "move_to_section" "button" in the "Mass Actions" "block"
    Then I should not see "Test Activity3" in the ".mimo-activities" "css_element"
    And I should see "Test Activity4" in the ".mimo-activities" "css_element"
    When I click on ".mimo-overview-btn" "css_element"
    And I click on ".mimo-overview-card[data-section-num='2'] .mimo-overview-card__link" "css_element"
    Then I should see "Test Activity3" in the ".mimo-activities" "css_element"
    And I should see "Test Activity5" in the ".mimo-activities" "css_element"

  @javascript
  Scenario: Check if a hidden wall can still be chosen as target in multi-section mode
    When I log in as "teacher1"
    And I am on "Test course 2" course homepage with editing mode on
    And I click on "Bulk actions" "button"
    And I click on "[data-for='sectionBulkSelect'] input" "css_element" in the ".mimo-overview-card[data-section-num='2']" "css_element"
    And I click on "[data-action='sectionAvailability']" "css_element" in the "sticky-footer" "region"
    And I click on "#hideSectionRadio" "css_element"
    And I click on "Apply" "button" in the ".modal" "css_element"
    And I click on "[data-action='bulkcancel']" "css_element"
    And I click on ".mimo-overview-card[data-section-num='1'] .mimo-overview-card__link" "css_element"
    And I add the "Mass Actions" block
    And I click on "Enable bulk editing" "button"
    Then the "disabled" attribute of "#block-massaction-control-section-list-moveto option[value='2']" "css_element" should not be set
    And the "disabled" attribute of "#block-massaction-control-section-list-duplicateto option[value='2']" "css_element" should not be set
    When I click on "Test Activity3" "checkbox"
    And I set the field "target_section_duplicating" in the "Mass Actions" "block" to "2"
    And I click on "duplicate_to_section" "button" in the "Mass Actions" "block"
    And I click on ".mimo-overview-btn" "css_element"
    And I click on ".mimo-overview-card[data-section-num='2'] .mimo-overview-card__link" "css_element"
    Then I should see "Test Activity3 (copy)" in the ".mimo-activities" "css_element"
