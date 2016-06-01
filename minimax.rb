require 'json'
require 'uri'
require 'net/http'
require 'time'

require_relative "connect4"

class MinimaxService
  # See https://github.com/lukasvermeer/connectfourservice
  def initialize
    @test_players = ['X','O']
    @test_ncolumns = 7
    @test_nrows = 6
    @test_board = Connect4Board.new(@test_ncolumns, @test_nrows,
    @test_players.first, @test_players.last)
    @url = 'http://connectfourservice.appspot.com/service'
    @host = 'connectfourservice.appspot.com'
    @path = '/service'
    @cookie = "NOT SET"
    uri = URI.parse(@url)
    @http = Net::HTTP.new(uri.host, uri.port)
    @user_agent = 'marc'+Time.now.to_f.to_s
  end

  def new_game
    #http = Net::HTTP.new(@host)
    #resp, result = Net::HTTP.get(@url+'?newgame=true', nil)
    #@cookie = resp.response['set-cookie'].split('; ')[0]

    params = {'newgame' => 'true', 'User-Agent' => @user_agent}
    uri = URI.parse("http://"+@host+@path)
    uri.query = URI.encode_www_form(params)
    puts uri.inspect
    resp = Net::HTTP.get_response(uri)
    puts resp.body
    puts resp.inspect
    @cookie = resp.response['set-cookie'].split('; ')[0]
    result = resp.body
    puts result
  end

  def move(column)
    @test_board.process_move(@test_players.sample, rand(@test_ncolumns))
    @test_board.display()
    result = @test_board.check_winner()

    http = Net::HTTP.new(@url+'?move='+column.to_s)
    request = Net::HTTP::Get.new(uri.request_uri)
    request['Cookie'] = @cookie
    response = http.request(request)
    puts response.body
  end

end

mini = MinimaxService.new
mini.new_game
mini.move(rand(7))


