require 'nokogiri'

class VisitorsController < ApplicationController

  helper_method :sort_column, :sort_direction

  def index
    xml_doc = Nokogiri::XML(open('http://www.cafeconleche.org/examples/baseball/1998statistics.xml'))

    players = parse_xml(xml_doc)

    direction = sort_direction == 'asc' ? 1 : -1
    players.sort_by! { |player| player[sort_column.to_sym] * direction}
    @players_paged = players.paginate(:page => params[:page], :per_page => 25)
  end

  private

  def parse_xml(xml_doc)
    player_list = []

    xml_doc.css('LEAGUE').each do |league|
      league.css('DIVISION').each do |division|
        division.css('TEAM').each do |team|
          team.css('PLAYER').each do |player|
            player_list << {
              surname: player.at_css('SURNAME').text,
              given_name: player.at_css('GIVEN_NAME').text,
              avg: player.at_css('AT_BATS').try(:text).to_i,
              hr: player.at_css('HOME_RUNS').try(:text).to_i,
              rbi: player.at_css('RBI').try(:text).to_i,
              runs: player.at_css('RUNS').try(:text).to_i,
              sb: player.at_css('STEALS').try(:text).to_i
            }
          end
        end
      end
    end

    player_list
  end

  def sort_column
    params[:sort] ? params[:sort] : 'avg'
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'desc'
  end
end
