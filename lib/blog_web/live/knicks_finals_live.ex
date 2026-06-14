defmodule BlogWeb.KnicksFinalsLive do
  @moduledoc """
  2026 NBA Finals — New York Knicks def. San Antonio Spurs, 4-1.

  "The Comeback Knicks": a self-contained editorial feature with D3 visualizations.
  All data (box scores, quarter line scores, recaps, key moments) is baked in,
  sourced from ESPN / NBA.com / CBS, June 2026. D3 v7 is vendored at
  /assets/d3.v7.min.js and charts read their data from a #kx-data data-attribute.
  """
  use BlogWeb, :live_view

  @title "KNICKS IN 5: By the numbers"
  @description "A dive into the numbers of the historic run the Knicks just completed to win the NBA championship"
  @og_image "https://www.bobbby.online/images/og-image.png"

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: @title,
       page_description: @description,
       meta_tags: [
         %{property: "og:title", content: @title},
         %{property: "og:description", content: @description},
         %{property: "og:type", content: "article"},
         %{property: "og:url", content: "https://www.bobbby.online/knicks"},
         %{property: "og:image", content: @og_image},
         %{property: "og:image:width", content: "1200"},
         %{property: "og:image:height", content: "630"},
         %{property: "og:site_name", content: "Thoughts & Tidbits"},
         %{name: "twitter:card", content: "summary_large_image"},
         %{name: "twitter:title", content: @title},
         %{name: "twitter:description", content: @description},
         %{name: "twitter:image", content: @og_image}
       ]
     )}
  end

  # ----------------------------------------------------------------------------
  # GAME DATA — meta, quarter line scores (by team abbrev), and full box scores.
  # ----------------------------------------------------------------------------
  defp games do
    [
      %{
        num: 1,
        date: "June 3, 2026",
        venue: "Frost Bank Center, San Antonio",
        away: "NYK",
        home: "SAS",
        away_score: 105,
        home_score: 95,
        series_after: "NYK leads 1-0",
        headline: "Brunson's fourth-quarter takeover steals the opener",
        dek:
          "Down 14 in the third, New York closed on a 22-9 run and held the Spurs to 19 in the fourth. Brunson scored 13 of his 30 in the final frame.",
        lines: %{"NYK" => [19, 29, 28, 29], "SAS" => [27, 28, 21, 19]},
        box: %{
          "NYK" => [
            p("Jalen Brunson", 37, "12-31", "2-9", "4-4", 3, 2, 0, 0, 4, 30),
            p("Karl-Anthony Towns", 34, "7-15", "0-2", "4-4", 12, 4, 0, 1, 2, 18),
            p("OG Anunoby", 31, "5-12", "3-6", "4-4", 3, 0, 1, 1, 0, 17),
            p("Landry Shamet", 33, "5-9", "3-6", "0-0", 1, 0, 0, 0, 0, 13),
            p("Mikal Bridges", 28, "3-6", "0-0", "3-4", 3, 3, 2, 0, 1, 9),
            p("Jose Alvarado", 11, "3-6", "1-3", "0-0", 4, 1, 1, 0, 1, 7),
            p("Miles McBride", 19, "2-7", "2-6", "0-0", 1, 4, 0, 1, 0, 6),
            p("Josh Hart", 27, "1-5", "0-3", "1-1", 15, 6, 4, 1, 0, 3),
            p("Mitchell Robinson", 13, "1-2", "0-0", "0-1", 6, 0, 0, 0, 0, 2),
            p("Jordan Clarkson", 6, "0-1", "0-1", "0-0", 1, 0, 0, 0, 0, 0)
          ],
          "SAS" => [
            p("Victor Wembanyama", 38, "6-21", "2-9", "12-13", 12, 2, 1, 3, 6, 26),
            p("Stephon Castle", 34, "7-16", "1-5", "2-2", 8, 3, 0, 0, 2, 17),
            p("Julian Champagnie", 31, "5-11", "5-10", "1-2", 10, 1, 0, 1, 0, 16),
            p("Dylan Harper", 28, "6-10", "1-4", "3-3", 8, 1, 1, 0, 1, 16),
            p("Devin Vassell", 36, "4-11", "1-6", "0-0", 9, 3, 0, 0, 1, 9),
            p("De'Aaron Fox", 38, "3-13", "0-4", "1-2", 4, 5, 1, 0, 3, 7),
            p("Keldon Johnson", 8, "1-4", "1-2", "0-0", 0, 0, 0, 0, 0, 3),
            p("Carter Bryant", 4, "0-1", "0-1", "1-2", 0, 0, 0, 0, 0, 1),
            p("Harrison Barnes", 12, "0-2", "0-2", "0-1", 2, 1, 0, 0, 0, 0),
            p("Luke Kornet", 10, "0-0", "0-0", "0-0", 1, 0, 1, 0, 0, 0)
          ]
        }
      },
      %{
        num: 2,
        date: "June 5, 2026",
        venue: "Frost Bank Center, San Antonio",
        away: "NYK",
        home: "SAS",
        away_score: 105,
        home_score: 104,
        series_after: "NYK leads 2-0",
        headline: "Wembanyama's jumper rims out as Knicks survive a 14-0 flurry",
        dek:
          "New York led by 14 in the fourth before San Antonio scored 14 straight to tie it. Brunson's free throw with 9.5 seconds left was the difference.",
        lines: %{"NYK" => [25, 31, 28, 21], "SAS" => [34, 18, 23, 29]},
        box: %{
          "NYK" => [
            p("Karl-Anthony Towns", 34, "8-12", "3-5", "2-2", 13, 4, 1, 1, 2, 21),
            p("Mikal Bridges", 41, "8-13", "4-6", "0-0", 6, 6, 1, 0, 1, 20),
            p("Jalen Brunson", 38, "7-25", "2-8", "4-5", 5, 6, 5, 0, 4, 20),
            p("OG Anunoby", 37, "5-10", "2-5", "5-5", 4, 3, 2, 2, 0, 17),
            p("Landry Shamet", 30, "5-12", "3-7", "0-0", 2, 2, 0, 1, 0, 13),
            p("Mitchell Robinson", 14, "2-2", "0-0", "3-6", 3, 0, 1, 1, 1, 7),
            p("Miles McBride", 18, "2-7", "1-3", "0-0", 2, 2, 0, 0, 2, 5),
            p("Jose Alvarado", 10, "0-4", "0-2", "2-3", 3, 2, 0, 0, 0, 2),
            p("Josh Hart", 18, "0-4", "0-2", "0-0", 6, 4, 1, 1, 2, 0)
          ],
          "SAS" => [
            p("Victor Wembanyama", 40, "11-21", "2-6", "5-8", 9, 2, 2, 4, 4, 29),
            p("De'Aaron Fox", 34, "8-12", "2-2", "2-2", 3, 5, 1, 1, 4, 20),
            p("Dylan Harper", 32, "6-12", "0-3", "3-4", 6, 3, 1, 0, 2, 15),
            p("Devin Vassell", 38, "4-9", "3-7", "3-3", 9, 5, 0, 1, 0, 14),
            p("Stephon Castle", 28, "5-14", "2-4", "2-4", 4, 4, 1, 0, 4, 14),
            p("Julian Champagnie", 36, "2-6", "2-5", "2-2", 4, 1, 0, 1, 0, 8),
            p("Keldon Johnson", 16, "1-4", "0-2", "1-2", 4, 2, 1, 0, 1, 3),
            p("Luke Kornet", 8, "0-0", "0-0", "1-2", 3, 0, 1, 0, 0, 1)
          ]
        }
      },
      %{
        num: 3,
        date: "June 8, 2026",
        venue: "Madison Square Garden, New York",
        away: "SAS",
        home: "NYK",
        away_score: 115,
        home_score: 111,
        series_after: "NYK leads 2-1",
        headline: "Spurs punch back: Wembanyama, Castle stave off the sweep",
        dek:
          "Facing a 0-3 hole, San Antonio came out 9-of-11 and snapped New York's 13-game playoff win streak behind Wembanyama's 32 and 23 off the bench from Castle.",
        lines: %{"SAS" => [33, 24, 35, 23], "NYK" => [22, 42, 27, 20]},
        box: %{
          "SAS" => [
            p("Victor Wembanyama", 39, "11-18", "2-4", "8-9", 8, 6, 2, 3, 1, 32),
            p("Stephon Castle", 38, "8-14", "2-5", "5-6", 5, 5, 1, 1, 2, 23),
            p("Dylan Harper", 32, "5-18", "1-8", "2-2", 9, 4, 0, 0, 0, 13),
            p("Julian Champagnie", 27, "4-9", "3-7", "1-2", 1, 3, 1, 0, 0, 12),
            p("De'Aaron Fox", 37, "4-14", "0-5", "4-4", 3, 8, 1, 2, 2, 12),
            p("Devin Vassell", 38, "3-4", "3-4", "2-3", 4, 0, 1, 0, 1, 11),
            p("Keldon Johnson", 17, "3-5", "0-0", "1-4", 2, 0, 1, 0, 2, 7),
            p("Carter Bryant", 4, "1-1", "1-1", "0-0", 0, 0, 0, 1, 0, 3),
            p("Luke Kornet", 9, "0-1", "0-0", "2-2", 5, 2, 1, 0, 0, 2)
          ],
          "NYK" => [
            p("Jalen Brunson", 35, "11-25", "3-5", "7-8", 5, 5, 0, 0, 5, 32),
            p("OG Anunoby", 38, "9-13", "3-7", "7-9", 5, 1, 0, 2, 1, 28),
            p("Josh Hart", 35, "6-10", "4-7", "0-0", 9, 5, 0, 0, 2, 16),
            p("Karl-Anthony Towns", 38, "4-10", "0-2", "3-3", 8, 1, 3, 2, 1, 11),
            p("Jordan Clarkson", 13, "4-7", "2-2", "0-0", 3, 1, 1, 0, 2, 10),
            p("Mitchell Robinson", 7, "2-3", "0-0", "1-2", 4, 0, 0, 0, 0, 5),
            p("Jose Alvarado", 12, "2-5", "0-2", "0-0", 3, 1, 0, 0, 1, 4),
            p("Landry Shamet", 23, "1-8", "1-7", "0-0", 4, 2, 0, 1, 0, 3),
            p("Mikal Bridges", 29, "1-5", "0-3", "0-0", 5, 2, 1, 1, 1, 2)
          ]
        }
      },
      %{
        num: 4,
        date: "June 10, 2026",
        venue: "Madison Square Garden, New York",
        away: "SAS",
        home: "NYK",
        away_score: 106,
        home_score: 107,
        series_after: "NYK leads 3-1",
        headline: "Down 29: the greatest comeback in Finals history",
        dek:
          "New York trailed 81-52 in the third and stormed all the way back, capped by OG Anunoby's tip-in with 1.2 seconds left — the largest comeback the NBA Finals has ever seen.",
        lines: %{"SAS" => [41, 35, 14, 16], "NYK" => [22, 27, 26, 32]},
        box: %{
          "SAS" => [
            p("Victor Wembanyama", 44, "9-25", "2-8", "4-7", 13, 1, 0, 3, 0, 24),
            p("Dylan Harper", 32, "8-12", "3-6", "2-2", 4, 3, 0, 0, 3, 21),
            p("De'Aaron Fox", 37, "6-16", "4-9", "2-2", 5, 7, 2, 1, 4, 18),
            p("Devin Vassell", 40, "6-9", "5-8", "1-1", 5, 4, 1, 0, 1, 18),
            p("Stephon Castle", 26, "2-7", "1-3", "8-8", 5, 5, 0, 0, 3, 13),
            p("Julian Champagnie", 33, "2-9", "1-7", "0-0", 5, 3, 4, 0, 0, 5),
            p("Carter Bryant", 5, "2-3", "1-1", "0-0", 1, 0, 1, 0, 0, 5),
            p("Keldon Johnson", 18, "1-5", "0-1", "0-0", 4, 1, 1, 0, 0, 2),
            p("Luke Kornet", 4, "0-0", "0-0", "0-0", 0, 0, 1, 0, 0, 0)
          ],
          "NYK" => [
            p("Jalen Brunson", 44, "12-25", "3-7", "9-11", 5, 7, 3, 0, 3, 36),
            p("OG Anunoby", 41, "10-15", "7-9", "6-6", 4, 1, 1, 1, 1, 33),
            p("Karl-Anthony Towns", 26, "4-5", "1-1", "4-4", 10, 2, 0, 0, 3, 13),
            p("Jose Alvarado", 16, "3-4", "2-3", "0-0", 2, 3, 0, 0, 1, 8),
            p("Mikal Bridges", 28, "3-9", "1-3", "0-0", 2, 2, 0, 0, 0, 7),
            p("Josh Hart", 33, "2-4", "1-2", "1-3", 8, 6, 2, 0, 2, 6),
            p("Jordan Clarkson", 5, "1-3", "0-1", "0-0", 1, 0, 0, 0, 2, 2),
            p("Mitchell Robinson", 13, "1-5", "0-0", "0-4", 5, 1, 0, 2, 1, 2),
            p("Landry Shamet", 21, "0-3", "0-2", "0-0", 2, 1, 0, 0, 0, 0),
            p("Miles McBride", 7, "0-4", "0-4", "0-0", 0, 0, 0, 0, 0, 0)
          ]
        }
      },
      %{
        num: 5,
        date: "June 13, 2026",
        venue: "Frost Bank Center, San Antonio",
        away: "NYK",
        home: "SAS",
        away_score: 94,
        home_score: 90,
        series_after: "NYK wins series 4-1 — CHAMPIONS",
        headline: "Brunson's 45 brings the title home",
        dek:
          "Down 16, the Knicks did what they did all series. Brunson erupted for 45 — including 13 straight in the fourth — to clinch Finals MVP and New York's first championship since 1973.",
        lines: %{"NYK" => [13, 24, 28, 29], "SAS" => [23, 19, 30, 18]},
        box: %{
          "NYK" => [
            p("Jalen Brunson", 41, "14-27", "4-7", "13-15", 3, 3, 2, 0, 3, 45),
            p("Mikal Bridges", 39, "5-10", "3-7", "1-2", 2, 4, 0, 1, 0, 14),
            p("Josh Hart", 39, "4-11", "3-6", "2-3", 11, 2, 0, 0, 1, 13),
            p("OG Anunoby", 33, "3-11", "1-5", "4-6", 8, 0, 3, 1, 1, 11),
            p("Landry Shamet", 13, "2-7", "1-4", "0-0", 1, 0, 0, 0, 0, 5),
            p("Karl-Anthony Towns", 23, "1-7", "0-2", "0-0", 10, 1, 3, 1, 5, 2),
            p("Mitchell Robinson", 20, "1-2", "0-0", "0-2", 10, 2, 0, 0, 0, 2),
            p("Jordan Clarkson", 6, "1-5", "0-2", "0-0", 1, 0, 0, 0, 0, 2),
            p("Jose Alvarado", 11, "0-5", "0-2", "0-0", 1, 0, 0, 0, 0, 0),
            p("Miles McBride", 13, "0-2", "0-2", "0-0", 0, 1, 0, 0, 0, 0),
            p("Ariel Hukporti", 2, "0-0", "0-0", "0-0", 1, 1, 0, 1, 0, 0)
          ],
          "SAS" => [
            p("Dylan Harper", 31, "10-19", "2-4", "3-5", 5, 4, 0, 1, 0, 25),
            p("Victor Wembanyama", 38, "7-19", "1-6", "4-5", 14, 2, 0, 5, 2, 19),
            p("Julian Champagnie", 31, "5-9", "4-8", "0-0", 7, 1, 1, 0, 4, 14),
            p("Devin Vassell", 39, "5-8", "2-5", "0-0", 7, 2, 2, 1, 0, 12),
            p("De'Aaron Fox", 37, "3-15", "1-8", "0-0", 0, 5, 2, 0, 1, 7),
            p("Keldon Johnson", 16, "2-5", "2-3", "1-2", 5, 0, 0, 0, 0, 7),
            p("Stephon Castle", 32, "1-10", "0-3", "4-6", 5, 4, 1, 0, 3, 6),
            p("Carter Bryant", 6, "0-0", "0-0", "0-0", 2, 0, 0, 0, 1, 0),
            p("Luke Kornet", 10, "0-1", "0-0", "0-0", 2, 0, 0, 0, 1, 0)
          ]
        }
      }
    ]
  end

  defp p(name, min, fg, tp, ft, reb, ast, stl, blk, to, pts) do
    %{name: name, min: min, fg: fg, tp: tp, ft: ft, reb: reb, ast: ast, stl: stl, blk: blk, to: to, pts: pts}
  end

  # Text callouts shown under each game's momentum chart.
  defp moments(1),
    do: [
      %{tag: "THE TURN", text: "Trailing by 14 in the third, the Knicks ripped off a 22-9 run to tie it at 76 entering the fourth."},
      %{tag: "THE STAND", text: "New York held San Antonio to 19 in the fourth and closed on an 11-0 run."},
      %{tag: "THE DAGGER", text: "After Wembanyama free throws put the Spurs up 95-94 with 2:16 left, Brunson answered with a corner three, then a spinning jumper while falling to the floor."}
    ]

  defp moments(2),
    do: [
      %{tag: "THE SCARE", text: "Up 14 in the fourth, the Knicks watched the Spurs reel off 14 unanswered to tie it."},
      %{tag: "THE GO-AHEAD", text: "Wembanyama's three-point play with 57 seconds left gave San Antonio its first lead in nearly two quarters, 104-102."},
      %{tag: "THE FINISH", text: "Wembanyama turned it over, Brunson made the go-ahead free throw with 9.5 left, and Wemby's would-be winner bounced off the rim."}
    ]

  defp moments(3),
    do: [
      %{tag: "FAST START", text: "San Antonio opened 9-of-11 and led 33-22 after one, refusing to go quietly down 0-3."},
      %{tag: "THE PUSHBACK", text: "A 42-point second quarter gave New York a 64-57 halftime lead and woke up the Garden."},
      %{tag: "THE CLOSE", text: "A cold fourth-quarter start sank the Knicks; Castle's late three and free throws iced it, 115-111."}
    ]

  defp moments(4),
    do: [
      %{tag: "THE HOLE", text: "San Antonio buried a Finals-record 14 threes in a 57-32 first half and led by 29, 81-52, in the third — bigger than Boston's 24-point Finals comeback over the Lakers in 2008."},
      %{tag: "THE CLAMP", text: "The Spurs went 3-of-17 from three after halftime. New York outscored them 58-30 over the final 24 minutes and held SA to 14 on 4-of-20 in the third."},
      %{tag: "THE SHOT", text: "After Castle's two free throws made it 106-105 with 30 left, Brunson's three clanked off the front rim and Anunoby tipped it home with 1.2 seconds to play. \"It feels cool,\" he said."}
    ]

  defp moments(5),
    do: [
      %{tag: "ANOTHER HOLE", text: "New York trailed by 16 — and rallied from a double-digit deficit for the fourth time in four series wins."},
      %{tag: "BRUNSON 45", text: "Brunson scored 45 on 14-of-27 with 13 straight in the fourth, breaking Willis Reed's franchise Finals record of 38 (1970) and locking up the Bill Russell Trophy."},
      %{tag: "53 YEARS", text: "A 29-18 fourth quarter ended the drought. The Villanova trio of Brunson, Bridges and Hart closed it out, and fireworks lit the New York sky."}
    ]

  # Annotated momentum points for the per-game D3 charts. `qi` is the quarter
  # index (0=tip, 4=final) the dot anchors to; `player` is who made the moment.
  defp plays(1),
    do: [
      %{qi: 3, tag: "76-76", player: "Brunson & Hart", text: "A 22-9 run to close the third ties it at 76."},
      %{qi: 4, tag: "W", player: "Jalen Brunson", text: "13 in the fourth — a corner three, then a spinning fadeaway. NY closes on an 11-0 run."}
    ]

  defp plays(2),
    do: [
      %{qi: 1, tag: "-9", player: "De'Aaron Fox", text: "Spurs pour in 34 in the first; New York trails early."},
      %{qi: 4, tag: "W", player: "Brunson / Wembanyama", text: "SA storms back with 14 straight; Brunson's free throw (9.5s) wins it as Wemby's jumper rims out."}
    ]

  defp plays(3),
    do: [
      %{qi: 1, tag: "-11", player: "Victor Wembanyama", text: "Spurs open 9-of-11 and lead 33-22."},
      %{qi: 2, tag: "+7", player: "Knicks", text: "A 42-point second quarter flips it to a 64-57 halftime lead."},
      %{qi: 4, tag: "L", player: "Stephon Castle", text: "Castle (23 off the bench) buries the late three and free throws; NY's 13-game streak ends."}
    ]

  defp plays(4),
    do: [
      %{qi: 1, tag: "-19", player: "Spurs barrage", text: "San Antonio hits a Finals-record 14 threes in the first half; up 57-32."},
      %{qi: 2, tag: "-29", player: "The hole", text: "Down 81-52 in the third — the deepest grave any Finals team has climbed out of."},
      %{qi: 3, tag: "clamp", player: "Towns & Alvarado", text: "Knicks hold SA to 14 in the third (4-20) and outscore them 58-30 after halftime."},
      %{qi: 4, tag: "W", player: "OG Anunoby", text: "Brunson misses, Anunoby tips it in with 1.2s left. 107-106. \"It feels cool.\""}
    ]

  defp plays(5),
    do: [
      %{qi: 1, tag: "-10", player: "Spurs", text: "NY trails by 16 — a double-digit hole for the fourth straight win."},
      %{qi: 3, tag: "-7", player: "Dylan Harper", text: "Harper's 25 keeps San Antonio ahead into the fourth."},
      %{qi: 4, tag: "W", player: "Jalen Brunson", text: "45 points, 13 straight in the fourth. Franchise Finals record. Title."}
    ]

  # Day-by-day timeline: game beats and off-day storylines between them.
  defp timeline do
    [
      %{date: "Jun 3", kind: :win, label: "GAME 1 · NYK 105, SAS 95",
        text: "Brunson's 13-point fourth quarter erases a 14-point deficit in San Antonio. The Knicks steal the opener for their 12th straight playoff win."},
      %{date: "Jun 4", kind: :news, label: "Wemby held to 6-of-21",
        text: "Headlines fixate on Victor Wembanyama's 6-of-21 night and six turnovers. New York grabbed home-court control with one road win."},
      %{date: "Jun 5", kind: :win, label: "GAME 2 · NYK 105, SAS 104",
        text: "The Knicks survive a 14-0 Spurs run; Wembanyama's would-be game-winner rims out and New York takes a 2-0 stranglehold — winning streak to 13."},
      %{date: "Jun 6-7", kind: :news, label: "The series shifts to MSG",
        text: "Drought talk swells in New York. Bryant Park watch parties overflow (21 arrested after Game 1), and James Dolan declines to put screens up inside the Garden."},
      %{date: "Jun 8", kind: :loss, label: "GAME 3 · SAS 115, NYK 111",
        text: "San Antonio refuses the sweep. Wembanyama goes for 32 and Stephon Castle adds 23 off the bench, snapping New York's 13-game playoff win streak."},
      %{date: "Jun 9", kind: :news, label: "Spurs still breathing",
        text: "A rematch of the 1999 Finals tightens to 2-1. The story turns to whether San Antonio can steal Game 4 and swing the series back to Texas even."},
      %{date: "Jun 10", kind: :win, label: "GAME 4 · NYK 107, SAS 106",
        text: "Down 29 (81-52), the Knicks author the largest comeback in Finals history. OG Anunoby's tip-in with 1.2 seconds left wins it. \"The most iconic shot in the history of New York basketball,\" says coach Mike Brown."},
      %{date: "Jun 11-12", kind: :news, label: "Anunoby tops the MVP ladder",
        text: "The basketball world replays the carom on loop; Anunoby vaults to the top of the Finals MVP ladder. New York returns to San Antonio one win from history."},
      %{date: "Jun 13", kind: :win, label: "GAME 5 · NYK 94, SAS 90",
        text: "Down 16, Brunson detonates for 45 and 13 straight in the fourth. The Knicks win their first title since 1973; Brunson is Finals MVP."},
      %{date: "Jun 14", kind: :news, label: "Ticker-tape parade",
        text: "New York plans the first ticker-tape parade in Knicks history. Wembanyama, 19-14-5 in the clincher: \"This is the biggest lesson of my life.\""}
    ]
  end

  defp by_the_numbers do
    [
      %{n: "29", l: "Point Game 4 hole erased — the largest comeback in Finals history (old mark: 24, 2008 Celtics)."},
      %{n: "58–30", l: "New York's second-half scoring edge during the Game 4 rally."},
      %{n: "14 → 3-17", l: "Spurs' first-half threes (a Finals record) vs. their 3-of-17 after the break in Game 4."},
      %{n: "45", l: "Brunson in Game 5 — the first 40-point Finals game by a Knick, past Willis Reed's 38 (1970)."},
      %{n: "4 / 4", l: "Knicks wins that came after trailing by double digits."},
      %{n: "1973", l: "The last time New York held the trophy — until now."}
    ]
  end

  # ----------------------------------------------------------------------------
  # STATS HELPERS
  # ----------------------------------------------------------------------------
  defp parse_ma(s) do
    case String.split(s, "-") do
      [m, a] -> {String.to_integer(m), String.to_integer(a)}
      _ -> {0, 0}
    end
  end

  defp sum_ma(lines, key) do
    Enum.reduce(lines, {0, 0}, fn l, {m, a} ->
      {dm, da} = parse_ma(Map.get(l, key))
      {m + dm, a + da}
    end)
  end

  defp pct(_, 0), do: "—"
  defp pct(m, a), do: :erlang.float_to_binary(m / a * 100, decimals: 1) <> "%"
  defp f1(x), do: :erlang.float_to_binary(x * 1.0, decimals: 1)

  defp winner(g), do: if(g.away_score > g.home_score, do: g.away, else: g.home)

  # Cumulative Knicks margin after each quarter: [0, m1, m2, m3, m4].
  defp ny_curve(g) do
    pairs = Enum.zip(g.lines["NYK"], g.lines["SAS"])

    {curve, _} =
      Enum.reduce(pairs, {[0], 0}, fn {n, s}, {acc, run} ->
        run = run + n - s
        {acc ++ [run], run}
      end)

    curve
  end

  defp player_pts(team, name) do
    Enum.map(games(), fn g ->
      case Enum.find(Map.get(g.box, team, []), &(&1.name == name)) do
        nil -> 0
        line -> line.pts
      end
    end)
  end

  defp series_avgs(team) do
    games()
    |> Enum.flat_map(fn g -> Map.get(g.box, team, []) end)
    |> Enum.group_by(& &1.name)
    |> Enum.map(fn {name, lines} ->
      gp = max(Enum.count(lines, &(&1.min > 0)), 1)
      {fgm, fga} = sum_ma(lines, :fg)
      {tpm, tpa} = sum_ma(lines, :tp)
      tot = fn k -> Enum.sum(Enum.map(lines, &Map.get(&1, k))) end

      %{
        name: name,
        gp: gp,
        ppg: tot.(:pts) / gp,
        rpg: tot.(:reb) / gp,
        apg: tot.(:ast) / gp,
        fg_pct: pct(fgm, fga),
        tp_pct: pct(tpm, tpa),
        pts: tot.(:pts)
      }
    end)
    |> Enum.sort_by(& &1.pts, :desc)
    |> Enum.take(5)
  end

  defp top_scorers(rows, n), do: rows |> Enum.sort_by(& &1.pts, :desc) |> Enum.take(n)

  # Trips to the foul line per game (FT attempts = fouls the other team committed).
  defp ft_battle do
    Enum.map(games(), fn g ->
      {_, nfa} = sum_ma(g.box["NYK"], :ft)
      {_, sfa} = sum_ma(g.box["SAS"], :ft)
      %{num: g.num, nyk: nfa, sas: sfa, win: winner(g) == "NYK"}
    end)
  end

  # Knicks scoring grid: top-10 players by total points, points + FG per game.
  defp heat_data do
    games()
    |> Enum.flat_map(& &1.box["NYK"])
    |> Enum.group_by(& &1.name)
    |> Enum.map(fn {name, lines} -> {name, Enum.sum(Enum.map(lines, & &1.pts))} end)
    |> Enum.sort_by(fn {_n, t} -> -t end)
    |> Enum.take(10)
    |> Enum.map(fn {name, _t} ->
      cells =
        Enum.map(games(), fn g ->
          case Enum.find(g.box["NYK"], &(&1.name == name)) do
            nil -> %{pts: nil, fg: "DNP"}
            l -> %{pts: l.pts, fg: l.fg}
          end
        end)

      %{name: name, cells: cells}
    end)
  end

  # Series-wide points by quarter, both teams.
  defp quarter_totals do
    tot = fn team ->
      Enum.reduce(games(), [0, 0, 0, 0], fn g, acc ->
        Enum.zip_with(acc, g.lines[team], &+/2)
      end)
    end

    %{nyk: tot.("NYK"), sas: tot.("SAS")}
  end

  # Final margin per game from the Knicks' point of view.
  defp margins do
    Enum.map(games(), fn g ->
      ny = if(g.away == "NYK", do: g.away_score, else: g.home_score)
      sa = if(g.away == "SAS", do: g.away_score, else: g.home_score)
      %{num: g.num, margin: ny - sa, win: ny > sa}
    end)
  end

  # JSON payload consumed by the D3 charts (read from #kx-data[data-kx]).
  defp chart_data do
    %{
      games:
        Enum.map(games(), fn g ->
          %{num: g.num, win: winner(g) == "NYK", curve: ny_curve(g), plays: plays(g.num)}
        end),
      brunson: player_pts("NYK", "Jalen Brunson"),
      wemby: player_pts("SAS", "Victor Wembanyama"),
      ft: ft_battle(),
      heat: heat_data(),
      quarters: quarter_totals(),
      margins: margins()
    }
  end

  # ----------------------------------------------------------------------------
  # RENDER
  # ----------------------------------------------------------------------------
  @impl true
  def render(assigns) do
    assigns =
      assigns
      |> assign(games: games(), timeline: timeline(), nums: by_the_numbers())
      |> assign(kx_json: Jason.encode!(chart_data()))

    ~H"""
    <style>
      .kx { background: #0b0f17; color: #e8eaed; font-family: "Helvetica Neue", Arial, sans-serif; min-height: 100vh; overflow-x: hidden; }
      .kx a.home { position: fixed; top: 12px; left: 14px; z-index: 30; color: #aeb4bd; font-size: 12px; text-decoration: none; letter-spacing: .04em; }
      .kx a.home:hover { color: #F58426; }
      .kx-wrap { max-width: 940px; margin: 0 auto; padding: 0 18px 90px; }

      .kx-hero { padding: 86px 0 22px; text-align: center; border-bottom: 1px solid #1d2532; }
      .kx-ey { color: #F58426; font-size: 13px; font-weight: 800; letter-spacing: .22em; text-transform: uppercase; }
      .kx-title { font-size: clamp(42px, 9.5vw, 96px); font-weight: 900; line-height: .92; margin: 10px 0 6px;
        background: linear-gradient(90deg, #F58426, #ffb16b); -webkit-background-clip: text; background-clip: text; color: transparent; }
      .kx-sub { font-size: clamp(15px, 2.4vw, 20px); color: #cdd2d9; font-weight: 600; }
      .kx-sub b { color: #006BB6; background: #fff; padding: 0 6px; border-radius: 3px; }
      .kx-final { margin-top: 12px; font-size: 13.5px; color: #8b93a0; }

      .kx-lead { font-size: 17px; line-height: 1.72; color: #d4d8de; margin: 30px auto 8px; max-width: 720px; }
      .kx-lead p { margin: 0 0 18px; }
      .kx-lead p:first-child::first-letter { font-size: 56px; font-weight: 900; float: left; line-height: .8; padding: 4px 12px 0 0; color: #F58426; }
      .kx-lead b { color: #fff; }
      .kx-lead .q { color: #ffb16b; font-style: italic; }

      .kx-h2 { font-size: 13px; font-weight: 800; letter-spacing: .2em; text-transform: uppercase; color: #F58426; margin: 56px 0 6px; padding-bottom: 8px; border-bottom: 1px solid #1d2532; }
      .kx-cap { font-size: 13px; color: #8b93a0; line-height: 1.55; margin: 0 0 14px; }

      .kx-chart { width: 100%; }
      .kx-chart svg { width: 100%; height: auto; display: block; }
      .kx-legend { display: flex; flex-wrap: wrap; gap: 14px; font-size: 12px; color: #aab0bb; margin: 8px 2px 0; }
      .kx-legend span { display: inline-flex; align-items: center; gap: 6px; }
      .kx-legend i { width: 16px; height: 3px; border-radius: 2px; display: inline-block; }

      .kx-tip { position: absolute; z-index: 50; pointer-events: none; background: #11161f; border: 1px solid #2a3444; border-left: 3px solid #F58426;
        padding: 7px 10px; border-radius: 5px; font-size: 12.5px; color: #e8eaed; line-height: 1.45; max-width: 260px; box-shadow: 0 6px 20px rgba(0,0,0,.5); transition: opacity .12s; }

      .kx-strip { display: grid; grid-template-columns: repeat(3, 1fr); gap: 1px; background: #1d2532; border: 1px solid #1d2532; }
      .kx-stat { background: #11161f; padding: 16px 14px; }
      .kx-stat .n { font-size: 26px; font-weight: 900; color: #F58426; line-height: 1; }
      .kx-stat .l { font-size: 12px; color: #9aa1ac; margin-top: 8px; line-height: 1.45; }
      @media (max-width: 620px) { .kx-strip { grid-template-columns: 1fr; } }

      /* Visualization deck — plain stacked sections on desktop, a swipe-to-flip card deck on mobile. */
      .kx-deckhint { display: none; }
      .kx-deck-nav { display: none; }
      .kx-replay { background: #11161f; border: 1px solid #2a3444; color: #9aa1ac; font-size: 11px; font-weight: 700; letter-spacing: .06em; text-transform: uppercase; padding: 6px 12px; border-radius: 5px; cursor: pointer; margin-top: 10px; }
      .kx-replay:hover { color: #F58426; border-color: #F58426; }
      @media (max-width: 680px) {
        /* On phones the whole thing is a fixed, full-screen, horizontally-swiped deck — no page scroll. */
        html, body { height: 100%; margin: 0; overflow: hidden; overscroll-behavior: none; }
        .kx { position: fixed; inset: 0; height: 100dvh; min-height: 0; overflow: hidden; }
        .kx > a.home { top: calc(env(safe-area-inset-top) + 10px); z-index: 46; font-size: 11px; }
        .kx-wrap { position: absolute; inset: 0; max-width: none; margin: 0; padding: 0; }
        .kx-deck.is-mobile { position: absolute; left: 0; right: 0; top: 0; bottom: 60px; width: 100%; overflow: hidden; }
        .kx-deck.is-mobile .kx-card { position: absolute; inset: 0; width: 100%; box-sizing: border-box;
          overflow-y: auto; overflow-x: hidden; -webkit-overflow-scrolling: touch; overscroll-behavior: contain;
          will-change: transform; transition: transform .5s cubic-bezier(.22,.61,.36,1);
          background: #0b0f17; border: none; border-radius: 0; margin: 0;
          padding: calc(env(safe-area-inset-top) + 52px) 18px calc(env(safe-area-inset-bottom) + 28px); }
        .kx-deck.is-mobile .kx-card .kx-h2 { margin-top: 0; }
        .kx-deck.is-mobile .kx-card-hero { display: flex; flex-direction: column; justify-content: center; }
        .kx-deck.is-mobile .kx-card-hero .kx-hero { padding: 0; border-bottom: none; }
        .kx-deck.is-mobile .kx-card-hero .kx-title { font-size: clamp(30px, 9vw, 50px); word-break: break-word; }
        .kx-deck.is-mobile .kx-card-hero .kx-sub { font-size: clamp(13px, 3.7vw, 17px); }
        .kx-deck.is-mobile .kx-card-hero .kx-final { font-size: clamp(11px, 3vw, 13px); }
        .kx-deck.is-mobile .kx-cap { font-size: clamp(12px, 3.4vw, 14px); }
        .kx-deck.is-mobile .kx-deckhint { display: block; text-align: center; font-size: 12px; color: #8b93a0; margin-top: 22px; letter-spacing: .04em; }
        .kx-deck.is-mobile .kx-game { margin: 0; }
        .kx-deck.is-mobile .kx-gridrow { grid-template-columns: 1fr; }
        /* Fixed pager */
        .kx-deck-nav { display: flex; align-items: center; gap: 12px; position: fixed; left: 0; right: 0; bottom: 0; z-index: 45; height: 60px; box-sizing: border-box;
          padding: 0 16px calc(env(safe-area-inset-bottom)); background: rgba(11,15,23,.96); border-top: 1px solid #1d2532; -webkit-backdrop-filter: blur(8px); backdrop-filter: blur(8px); }
        .kx-nav-btn { flex: 0 0 auto; width: 44px; height: 38px; background: #11161f; border: 1px solid #2a3444; color: #e8eaed; font-size: 19px; line-height: 1; border-radius: 9px; cursor: pointer; }
        .kx-nav-btn:disabled { opacity: .28; }
        .kx-nav-btn:active { background: #1a2230; }
        .kx-prog { flex: 1; height: 4px; background: #1d2532; border-radius: 2px; overflow: hidden; }
        .kx-prog-fill { height: 100%; width: 0; background: linear-gradient(90deg, #F58426, #ffb16b); transition: width .4s cubic-bezier(.22,.61,.36,1); }
        .kx-count { flex: 0 0 auto; font-size: 12px; color: #9aa1ac; font-variant-numeric: tabular-nums; min-width: 50px; text-align: center; }
      }

      .kx-tl { position: relative; padding-left: 22px; margin-top: 10px; }
      .kx-tl::before { content: ""; position: absolute; left: 5px; top: 4px; bottom: 4px; width: 2px; background: #1d2532; }
      .kx-beat { position: relative; padding: 0 0 22px 16px; }
      .kx-beat::before { content: ""; position: absolute; left: -22px; top: 3px; width: 12px; height: 12px; border-radius: 50%; border: 2px solid #0b0f17; }
      .kx-beat.win::before { background: #F58426; }
      .kx-beat.loss::before { background: #5a6675; }
      .kx-beat.news::before { background: #11161f; border-color: #2a3444; width: 9px; height: 9px; left: -20px; top: 5px; }
      .kx-beat .d { font-size: 11px; color: #8b93a0; letter-spacing: .08em; text-transform: uppercase; }
      .kx-beat .lab { font-size: 15px; font-weight: 800; margin: 1px 0 4px; }
      .kx-beat.win .lab { color: #fff; }
      .kx-beat.loss .lab { color: #b9c0cb; }
      .kx-beat.news .lab { color: #aeb4bd; font-weight: 700; font-size: 14px; }
      .kx-beat .t { font-size: 13.5px; color: #aab0bb; line-height: 1.5; }

      .kx-game { border: 1px solid #1d2532; border-radius: 8px; overflow: hidden; margin-bottom: 26px; background: #0e131c; }
      .kx-gh { padding: 16px 18px; border-bottom: 1px solid #1d2532; }
      .kx-gh .meta { display: flex; justify-content: space-between; align-items: baseline; flex-wrap: wrap; gap: 6px; }
      .kx-gh .gnum { font-size: 12px; font-weight: 800; letter-spacing: .12em; color: #F58426; text-transform: uppercase; }
      .kx-gh .gdate { font-size: 12px; color: #8b93a0; }
      .kx-gh h3 { font-size: clamp(19px, 3.6vw, 26px); font-weight: 900; margin: 8px 0 6px; color: #fff; line-height: 1.12; }
      .kx-gh .dek { font-size: 14px; color: #aab0bb; line-height: 1.55; }
      .kx-gh .ven { font-size: 11.5px; color: #6f7785; margin-top: 8px; }

      .kx-gridrow { display: grid; grid-template-columns: 1.15fr 1fr; gap: 0; border-bottom: 1px solid #1d2532; }
      @media (max-width: 680px) { .kx-gridrow { grid-template-columns: 1fr; } }
      .kx-momwrap { padding: 12px 14px; border-right: 1px solid #1d2532; }
      @media (max-width: 680px) { .kx-momwrap { border-right: none; border-bottom: 1px solid #1d2532; } }
      .kx-sidewrap { padding: 12px 16px; }

      .kx-ls { width: 100%; border-collapse: collapse; font-size: 13px; }
      .kx-ls th, .kx-ls td { padding: 5px 8px; text-align: center; }
      .kx-ls th { font-size: 10px; color: #7e8693; text-transform: uppercase; letter-spacing: .06em; font-weight: 700; }
      .kx-ls td.tm { text-align: left; font-weight: 800; }
      .kx-ls td.f { font-weight: 900; font-size: 15px; }
      .kx-ls tr.w td { color: #fff; }
      .kx-ls tr.w td.tm { color: #F58426; }
      .kx-ls tr.l td { color: #98a0ac; }

      .kx-chips { margin-top: 12px; }
      .kx-chips .lbl { font-size: 10px; color: #7e8693; text-transform: uppercase; letter-spacing: .08em; margin: 8px 0 5px; }
      .kx-chip { display: inline-flex; align-items: center; gap: 5px; font-size: 12px; background: #11161f; border: 1px solid #232d3b; border-radius: 20px; padding: 3px 10px; margin: 0 5px 5px 0; color: #c6ccd5; }
      .kx-chip b { color: #fff; }
      .kx-chip.ny { border-left: 3px solid #F58426; }
      .kx-chip.sa { border-left: 3px solid #8d99ae; }

      .kx-moments { padding: 8px 18px 14px; display: grid; gap: 9px; }
      .kx-mo { border-left: 3px solid #F58426; background: #11161f; padding: 9px 14px; border-radius: 0 6px 6px 0; }
      .kx-mo .tag { font-size: 10.5px; font-weight: 800; letter-spacing: .12em; color: #F58426; text-transform: uppercase; }
      .kx-mo .mt { font-size: 13.5px; color: #cdd2d9; line-height: 1.5; margin-top: 3px; }

      details.kx-box { border-top: 1px solid #1d2532; }
      details.kx-box > summary { padding: 12px 18px; cursor: pointer; font-size: 12px; font-weight: 700; letter-spacing: .08em; text-transform: uppercase; color: #9aa1ac; list-style: none; }
      details.kx-box > summary::-webkit-details-marker { display: none; }
      details.kx-box > summary::after { content: " ▾"; color: #F58426; }
      details.kx-box[open] > summary::after { content: " ▴"; }
      .kx-bt { padding: 0 8px 14px; overflow-x: auto; }
      .kx-bt h4 { font-size: 12px; color: #F58426; font-weight: 800; margin: 12px 10px 6px; letter-spacing: .05em; }
      table.kx-stats { width: 100%; border-collapse: collapse; font-size: 12.5px; min-width: 560px; }
      table.kx-stats th { font-size: 10px; color: #7e8693; text-transform: uppercase; letter-spacing: .04em; padding: 6px 8px; text-align: right; border-bottom: 1px solid #1d2532; }
      table.kx-stats th.nm { text-align: left; }
      table.kx-stats td { padding: 6px 8px; text-align: right; border-bottom: 1px solid #141b26; color: #c6ccd5; }
      table.kx-stats td.nm { text-align: left; font-weight: 600; color: #e8eaed; }
      table.kx-stats td.pts { font-weight: 800; color: #fff; }
      table.kx-stats tr.tot td { border-top: 1px solid #2a3444; border-bottom: none; color: #8b93a0; font-weight: 700; padding-top: 8px; }

      .kx-mvp { display: flex; gap: 16px; align-items: center; background: linear-gradient(120deg, #11161f, #0e131c); border: 1px solid #2a3444; border-left: 4px solid #F58426; border-radius: 8px; padding: 18px; margin: 6px 0 22px; }
      .kx-mvp .badge { font-size: 11px; font-weight: 800; letter-spacing: .14em; color: #F58426; text-transform: uppercase; }
      .kx-mvp .who { font-size: 26px; font-weight: 900; color: #fff; line-height: 1.05; margin: 3px 0 6px; }
      .kx-mvp .line { font-size: 13.5px; color: #aab0bb; line-height: 1.5; }
      .kx-leadtbl { overflow-x: auto; margin-bottom: 26px; }
      .kx-leadtbl h4 { font-size: 13px; color: #cdd2d9; margin: 0 0 8px; font-weight: 800; }
      .kx-leadtbl h4 span { color: #6f7785; font-weight: 600; }

      .kx-foot { color: #6f7785; font-size: 11.5px; line-height: 1.7; margin-top: 44px; border-top: 1px solid #1d2532; padding-top: 16px; }
    </style>

    <div class="kx">
      <a href="/" class="home">← bobbby.online</a>
      <div class="kx-wrap">
        <div class="kx-deck" id="kx-deck">
        <!-- HERO -->
        <div class="kx-card kx-card-hero">
        <div class="kx-hero">
          <div class="kx-ey">2026 NBA Finals</div>
          <div class="kx-title">THE COMEBACK KNICKS</div>
          <div class="kx-sub"><b>NEW YORK</b> — NBA champions for the first time since 1973</div>
          <div class="kx-final">def. San Antonio Spurs 4-1 · a rematch of the 1999 Finals, 27 years later</div>
        </div>
        <div class="kx-deckhint">Swipe ▶ to move through the story</div>
        </div>

        <!-- FEATURE LEAD -->
        <div class="kx-card">
        <div class="kx-lead">
          <p>
            Fifty-three years, and they couldn't do it the easy way for a single night. New York won the
            2026 title in five games and trailed by double digits in <b>all four of the wins</b> — by 14 in
            Game 1, 14 in Game 2, 29 in Game 4, 16 in the close-out. You don't back into a championship
            like this. The Knicks spent two weeks falling down the stairs and landing on the trophy.
          </p>
          <p>
            Game 4 is the one they'll teach. Down 81-52 in the third, the Spurs had buried a Finals-record
            14 first-half threes and the Garden had gone quiet in the bad way. Then San Antonio missed
            14 of its next 17 from deep, New York outscored them 58-30 after the break, and Brunson's
            airball off the front rim found OG Anunoby, who put it back with 1.2 seconds left.
            <span class="q">"It feels cool,"</span> Anunoby said — the most points-per-word anyone scored all series.
          </p>
          <p>
            Three nights later Brunson scored <b>45</b> — 13 in a row in the fourth — the first 40-point Finals
            game any Knick has ever played, one better in the record book than Willis Reed in '70. Victor
            Wembanyama, 19 and 14 and five blocks in defeat, called it
            <span class="q">"the biggest lesson of my life."</span> He's 22. He'll be back.
          </p>
          <p>
            The chart below is the whole series in one picture: five lines, four of which dive under the
            zero and claw back over it before the buzzer. Nobody should be able to do this once.
          </p>
        </div>
        </div>

        <!-- BY THE NUMBERS -->
        <div class="kx-card">
        <div class="kx-h2">By the Numbers</div>
        <div class="kx-strip">
          <%= for s <- @nums do %>
            <div class="kx-stat"><div class="n">{s.n}</div><div class="l">{s.l}</div></div>
          <% end %>
        </div>
        </div>

        <!-- VISUALIZATIONS -->
          <div class="kx-card">
            <div class="kx-h2">Living Below the Line</div>
            <div class="kx-cap">Knicks margin after each quarter, all five games. Below zero means New York trailed. The four wins (solid) all finish above the line; the lone loss (Game 3, dashed) doesn't. Hover any point.</div>
            <div id="kx-hero-chart" class="kx-chart" phx-update="ignore"></div>
            <div class="kx-legend">
              <span><i style="background:#4cc9f0"></i>Game 1</span>
              <span><i style="background:#ffd166"></i>Game 2</span>
              <span><i style="background:#8d99ae"></i>Game 3 (L)</span>
              <span><i style="background:#ef476f"></i>Game 4</span>
              <span><i style="background:#F58426"></i>Game 5</span>
            </div>
          </div>

          <div class="kx-card">
            <div class="kx-h2">The Shot</div>
            <div class="kx-cap">Game 4, 1.2 seconds left, Knicks down one. Brunson's three clangs off the front rim — and OG Anunoby flies in to tip it home. The largest comeback in Finals history, won at the buzzer.</div>
            <div id="kx-shot-chart" class="kx-chart" phx-update="ignore"></div>
            <button type="button" class="kx-replay" onclick="window.kxReplayShot &amp;&amp; window.kxReplayShot()">▸ Replay</button>
          </div>

          <div class="kx-card">
            <div class="kx-h2">The Miss</div>
            <div class="kx-cap">Game 2, tie game, final seconds. Wembanyama rises for the win — and it rims out. New York escapes 105-104 and goes up 2-0.</div>
            <div id="kx-miss-chart" class="kx-chart" phx-update="ignore"></div>
            <button type="button" class="kx-replay" onclick="window.kxReplayMiss &amp;&amp; window.kxReplayMiss()">▸ Replay</button>
          </div>

          <div class="kx-card">
            <div class="kx-h2">From 29 Down</div>
            <div class="kx-cap">Game 4. New York trailed 81-52 in the third — about as dead as a Finals team gets — then completed the largest comeback in Finals history.</div>
            <div id="kx-climb-chart" class="kx-chart" phx-update="ignore"></div>
          </div>

          <div class="kx-card">
            <div class="kx-h2">Brunson's 45</div>
            <div class="kx-cap">Game 5, title on the line. Brunson poured in 45 — 13 straight in the fourth — passing Willis Reed's 1970 mark for the most by a Knick in a Finals game.</div>
            <div id="kx-forty-chart" class="kx-chart" phx-update="ignore"></div>
          </div>

          <div class="kx-card">
            <div class="kx-h2">Slow Starts, Big Finishes</div>
            <div class="kx-cap">Total points by quarter across the series. San Antonio won the first quarters by a combined 57 — and lost every other quarter. New York took the fourth by 26. The Knicks spotted the Spurs the start, then owned the night.</div>
            <div id="kx-quarters-chart" class="kx-chart" phx-update="ignore"></div>
          </div>

          <div class="kx-card">
            <div class="kx-h2">Decided by a Whisker</div>
            <div class="kx-cap">Final margin, Knicks' view. Four of five games were single digits and two came down to a single point — Brunson's free throw in Game 2, Anunoby's tip in Game 4. It was never as tidy as 4-1 sounds.</div>
            <div id="kx-margins-chart" class="kx-chart" phx-update="ignore"></div>
          </div>

          <div class="kx-card">
            <div class="kx-h2">Brunson vs. Wembanyama</div>
            <div class="kx-cap">Points per game. Brunson (orange) climbed to a 45-point crescendo; the 22-year-old Wembanyama (silver) carried San Antonio but ran out of runway.</div>
            <div id="kx-duel-chart" class="kx-chart" phx-update="ignore"></div>
          </div>

          <div class="kx-card">
            <div class="kx-h2">Who Carried Each Night</div>
            <div class="kx-cap">Knicks points by player and game. Brunson glows all five nights, but the title was a committee job — Anunoby erupts in Games 3-4, Bridges and Hart close it out in Game 5. Hover for shooting.</div>
            <div id="kx-heat-chart" class="kx-chart" phx-update="ignore"></div>
          </div>

          <div class="kx-card">
            <div class="kx-h2">The Free-Throw Battle</div>
            <div class="kx-cap">Trips to the line per game. Each Spurs free throw is a foul New York committed. The Knicks hacked San Antonio to the line 25, 27, then 32 times in the first three games — Game 3 (32) was their only loss. Then they stopped fouling (20, 18) and started drawing them (28, 28). The series turned on the whistle.</div>
            <div id="kx-fouls-chart" class="kx-chart" phx-update="ignore"></div>
          </div>

        <!-- TIMELINE -->
        <div class="kx-card">
        <div class="kx-h2">The Series, Day by Day</div>
        <div class="kx-tl">
          <%= for beat <- @timeline do %>
            <div class={"kx-beat #{beat.kind}"}>
              <div class="d">{beat.date}</div>
              <div class="lab">{beat.label}</div>
              <div class="t">{beat.text}</div>
            </div>
          <% end %>
        </div>
        </div>

        <!-- GAME BY GAME -->
        <%= for g <- @games do %>
          <% w = winner(g) %>
          <div class="kx-game kx-card kx-card-flush">
            <div class="kx-gh">
              <div class="meta">
                <span class="gnum">Game {g.num}</span>
                <span class="gdate">{g.date} · {g.series_after}</span>
              </div>
              <h3>{g.headline}</h3>
              <div class="dek">{g.dek}</div>
              <div class="ven">{g.venue}</div>
            </div>

            <div class="kx-gridrow">
              <div class="kx-momwrap">
                <div id={"kx-mom-#{g.num}"} class="kx-chart" phx-update="ignore"></div>
              </div>
              <div class="kx-sidewrap">
                <table class="kx-ls">
                  <thead>
                    <tr><th>Team</th><th>1</th><th>2</th><th>3</th><th>4</th><th>F</th></tr>
                  </thead>
                  <tbody>
                    <%= for tm <- [g.away, g.home] do %>
                      <% sc = if(tm == g.away, do: g.away_score, else: g.home_score) %>
                      <tr class={if(tm == w, do: "w", else: "l")}>
                        <td class="tm">{tm}</td>
                        <%= for q <- g.lines[tm] do %>
                          <td>{q}</td>
                        <% end %>
                        <td class="f">{sc}</td>
                      </tr>
                    <% end %>
                  </tbody>
                </table>

                <div class="kx-chips">
                  <div class="lbl">Who showed up</div>
                  <%= for r <- top_scorers(g.box[g.away], 3) do %>
                    <span class={"kx-chip #{if(g.away == "NYK", do: "ny", else: "sa")}"}>{r.name} <b>{r.pts}</b></span>
                  <% end %>
                  <%= for r <- top_scorers(g.box[g.home], 3) do %>
                    <span class={"kx-chip #{if(g.home == "NYK", do: "ny", else: "sa")}"}>{r.name} <b>{r.pts}</b></span>
                  <% end %>
                </div>
              </div>
            </div>

            <div class="kx-moments">
              <%= for m <- moments(g.num) do %>
                <div class="kx-mo">
                  <div class="tag">{m.tag}</div>
                  <div class="mt">{m.text}</div>
                </div>
              <% end %>
            </div>
          </div>
        <% end %>

        <!-- LEADERS -->
        <div class="kx-card">
        <div class="kx-h2">Series Leaders</div>
        <div class="kx-mvp">
          <div>
            <div class="badge">Bill Russell Trophy · Finals MVP</div>
            <div class="who">Jalen Brunson</div>
            <div class="line">
              32.6 PPG · 4.6 APG · 4.2 RPG · 42.1% FG · 38.9% 3PT over five games.
              His 45 in the clincher broke Willis Reed's franchise Finals record (38, 1970) and made him the first Knick to drop 40 in a Finals game.
            </div>
          </div>
        </div>

        <div class="kx-leadtbl">
          <h4>New York Knicks <span>· per game</span></h4>
          {render_leaders(assign(assigns, :leaders, series_avgs("NYK")))}
        </div>
        <div class="kx-leadtbl">
          <h4>San Antonio Spurs <span>· per game</span></h4>
          {render_leaders(assign(assigns, :leaders, series_avgs("SAS")))}
        </div>

        <div class="kx-foot">
          Box scores, quarter line scores, and recaps via ESPN, NBA.com and CBS Sports, June 2026.
          Comeback margins and game-winning sequences reflect those accounts. Charts drawn with D3 v7.
          Built as a Phoenix LiveView page on bobbby.online.
        </div>
        </div>
        </div>
        <!-- end deck -->

        <div class="kx-deck-nav" id="kx-deck-nav">
          <button type="button" id="kx-prev" class="kx-nav-btn" aria-label="Previous">‹</button>
          <div class="kx-prog"><div class="kx-prog-fill" id="kx-prog-fill"></div></div>
          <span class="kx-count" id="kx-count">1 / 1</span>
          <button type="button" id="kx-next" class="kx-nav-btn" aria-label="Next">›</button>
        </div>

        <div id="kx-data" data-kx={@kx_json} style="display:none"></div>
      </div>
    </div>

    <script src="/static/d3.v7.min.js">
    </script>
    <script>
      (function () {
        var COLORS = {1:'#4cc9f0', 2:'#ffd166', 3:'#8d99ae', 4:'#ef476f', 5:'#F58426'};
        var STAGES = ['Tip','Q1','Q2','Q3','Final'];
        var TT;

        function tip() {
          if (!TT) { TT = document.createElement('div'); TT.className = 'kx-tip'; TT.style.opacity = '0'; document.body.appendChild(TT); }
          return TT;
        }
        function showTip(html, x, y) {
          var t = tip(); t.innerHTML = html; t.style.opacity = '1';
          var ww = window.innerWidth;
          var left = x + 14; if (left > ww - 270) left = x - 270;
          t.style.left = left + 'px'; t.style.top = (y + 14) + 'px';
        }
        function hideTip() { if (TT) TT.style.opacity = '0'; }
        function clear(id) { var e = document.getElementById(id); if (e) e.innerHTML = ''; return e; }

        function renderHero(data) {
          var host = clear('kx-hero-chart'); if (!host || !window.d3) return;
          var W = host.clientWidth || 880, H = 400, m = {t:26, r:26, b:36, l:42};
          var iw = W - m.l - m.r, ih = H - m.t - m.b;
          var svg = d3.select(host).append('svg').attr('viewBox', '0 0 ' + W + ' ' + H);
          var g = svg.append('g').attr('transform', 'translate(' + m.l + ',' + m.t + ')');
          var x = d3.scalePoint().domain([0,1,2,3,4]).range([0, iw]);
          var all = []; data.games.forEach(function (gm) { all = all.concat(gm.curve); });
          var y = d3.scaleLinear().domain([Math.min(-30, d3.min(all)), Math.max(12, d3.max(all))]).nice().range([ih, 0]);

          var ticks = y.ticks(7);
          g.selectAll('.grid').data(ticks).enter().append('line')
            .attr('x1', 0).attr('x2', iw).attr('y1', function (d) { return y(d); }).attr('y2', function (d) { return y(d); })
            .attr('stroke', function (d) { return d === 0 ? '#3a475a' : '#161d29'; })
            .attr('stroke-width', function (d) { return d === 0 ? 2 : 1; });
          g.selectAll('.yl').data(ticks).enter().append('text')
            .attr('x', -8).attr('y', function (d) { return y(d) + 3; }).attr('text-anchor', 'end')
            .attr('fill', '#6f7785').attr('font-size', 10).text(function (d) { return (d > 0 ? '+' : '') + d; });
          g.selectAll('.xl').data(STAGES).enter().append('text')
            .attr('x', function (d, i) { return x(i); }).attr('y', ih + 20).attr('text-anchor', 'middle')
            .attr('fill', '#8b93a0').attr('font-size', 11).text(function (d) { return d; });

          var line = d3.line().x(function (d, i) { return x(i); }).y(function (d) { return y(d); }).curve(d3.curveMonotoneX);

          data.games.forEach(function (gm) {
            var path = g.append('path').datum(gm.curve).attr('fill', 'none')
              .attr('stroke', COLORS[gm.num]).attr('stroke-width', gm.num === 4 ? 3.6 : 2).attr('opacity', 0.95).attr('d', line);
            if (gm.win) {
              var len = path.node().getTotalLength();
              path.attr('stroke-dasharray', len + ' ' + len).attr('stroke-dashoffset', len)
                .transition().duration(1100).delay(gm.num * 120).ease(d3.easeCubicOut).attr('stroke-dashoffset', 0);
            } else {
              path.attr('stroke-dasharray', '6,4');
            }
            g.selectAll('.v' + gm.num).data(gm.curve).enter().append('circle')
              .attr('cx', function (d, i) { return x(i); }).attr('cy', function (d) { return y(d); })
              .attr('r', gm.num === 4 ? 4 : 3.2).attr('fill', COLORS[gm.num]).attr('stroke', '#0b0f17').attr('stroke-width', 1).style('cursor', 'pointer')
              .on('mousemove', function (ev, d) { var i = gm.curve.indexOf(d); showTip('<b style="color:' + COLORS[gm.num] + '">Game ' + gm.num + '</b><br>' + STAGES[i] + ': ' + (d > 0 ? '+' : '') + d, ev.pageX, ev.pageY); })
              .on('mouseout', hideTip);
            g.append('text').attr('x', x(4) + 7).attr('y', y(gm.curve[4]) + 3).attr('fill', COLORS[gm.num])
              .attr('font-size', 10).attr('font-weight', 700).text('G' + gm.num);
          });

          var g4 = data.games.filter(function (z) { return z.num === 4; })[0];
          if (g4) {
            var ax = x(2), ay = y(g4.curve[2]);
            g.append('text').attr('x', ax + 8).attr('y', ay + 4).attr('fill', '#ef476f').attr('font-size', 11).attr('font-weight', 700).text('▲ down 29 in the 3rd');
            g.append('text').attr('x', ax + 8).attr('y', ay + 18).attr('fill', '#9aa1ac').attr('font-size', 10).text('largest comeback in Finals history');
          }
        }

        function renderDuel(data) {
          var host = clear('kx-duel-chart'); if (!host || !window.d3) return;
          var W = host.clientWidth || 880, H = 300, m = {t:18, r:14, b:38, l:32};
          var iw = W - m.l - m.r, ih = H - m.t - m.b;
          var svg = d3.select(host).append('svg').attr('viewBox', '0 0 ' + W + ' ' + H);
          var g = svg.append('g').attr('transform', 'translate(' + m.l + ',' + m.t + ')');
          var gms = [1,2,3,4,5];
          var x0 = d3.scaleBand().domain(gms).range([0, iw]).padding(0.28);
          var x1 = d3.scaleBand().domain(['b','w']).range([0, x0.bandwidth()]).padding(0.12);
          var y = d3.scaleLinear().domain([0, 50]).range([ih, 0]);

          g.selectAll('.gd').data(y.ticks(5)).enter().append('line').attr('x1', 0).attr('x2', iw)
            .attr('y1', function (d) { return y(d); }).attr('y2', function (d) { return y(d); }).attr('stroke', '#161d29');
          g.selectAll('.yl').data(y.ticks(5)).enter().append('text').attr('x', -8).attr('y', function (d) { return y(d) + 3; })
            .attr('text-anchor', 'end').attr('fill', '#6f7785').attr('font-size', 10).text(function (d) { return d; });

          gms.forEach(function (gn, i) {
            var grp = g.append('g').attr('transform', 'translate(' + x0(gn) + ',0)');
            var vals = [['b', data.brunson[i], '#F58426', 'Brunson'], ['w', data.wemby[i], '#cbd2da', 'Wembanyama']];
            vals.forEach(function (pair) {
              grp.append('rect').attr('x', x1(pair[0])).attr('width', x1.bandwidth()).attr('y', ih).attr('height', 0)
                .attr('fill', pair[2]).attr('rx', 2).style('cursor', 'pointer')
                .on('mousemove', function (ev) { showTip('<b style="color:' + pair[2] + '">' + pair[3] + '</b><br>Game ' + gn + ': ' + pair[1] + ' pts', ev.pageX, ev.pageY); })
                .on('mouseout', hideTip)
                .transition().duration(800).delay(i * 90).attr('y', y(pair[1])).attr('height', ih - y(pair[1]));
              grp.append('text').attr('x', x1(pair[0]) + x1.bandwidth() / 2).attr('y', y(pair[1]) - 4).attr('text-anchor', 'middle')
                .attr('fill', pair[2]).attr('font-size', 10).attr('font-weight', 700).attr('opacity', 0).text(pair[1])
                .transition().delay(i * 90 + 520).duration(300).attr('opacity', 1);
            });
            grp.append('text').attr('x', x0.bandwidth() / 2).attr('y', ih + 16).attr('text-anchor', 'middle').attr('fill', '#8b93a0').attr('font-size', 10).text('G' + gn);
          });
        }

        function renderMomentum(gm) {
          var host = clear('kx-mom-' + gm.num); if (!host || !window.d3) return;
          var W = host.clientWidth || 520, H = 180, m = {t:18, r:14, b:22, l:28};
          var iw = W - m.l - m.r, ih = H - m.t - m.b;
          var svg = d3.select(host).append('svg').attr('viewBox', '0 0 ' + W + ' ' + H);
          var defs = svg.append('defs');
          var gid = 'kxgrad' + gm.num;
          var lg = defs.append('linearGradient').attr('id', gid).attr('x1', 0).attr('x2', 0).attr('y1', 0).attr('y2', 1);
          lg.append('stop').attr('offset', '0%').attr('stop-color', COLORS[gm.num]).attr('stop-opacity', 0.34);
          lg.append('stop').attr('offset', '100%').attr('stop-color', COLORS[gm.num]).attr('stop-opacity', 0.02);
          var g = svg.append('g').attr('transform', 'translate(' + m.l + ',' + m.t + ')');
          var x = d3.scalePoint().domain([0,1,2,3,4]).range([0, iw]);
          var ext = d3.extent(gm.curve);
          var y = d3.scaleLinear().domain([Math.min(ext[0], -3) - 3, Math.max(ext[1], 3) + 5]).range([ih, 0]);
          var col = COLORS[gm.num];

          g.append('line').attr('x1', 0).attr('x2', iw).attr('y1', y(0)).attr('y2', y(0)).attr('stroke', '#3a475a').attr('stroke-dasharray', '3,3');
          var area = d3.area().x(function (d, i) { return x(i); }).y0(y(0)).y1(function (d) { return y(d); }).curve(d3.curveMonotoneX);
          g.append('path').datum(gm.curve).attr('fill', 'url(#' + gid + ')').attr('d', area);
          var line = d3.line().x(function (d, i) { return x(i); }).y(function (d) { return y(d); }).curve(d3.curveMonotoneX);
          var path = g.append('path').datum(gm.curve).attr('fill', 'none').attr('stroke', col).attr('stroke-width', 2.5).attr('d', line);
          var len = path.node().getTotalLength();
          path.attr('stroke-dasharray', len + ' ' + len).attr('stroke-dashoffset', len).transition().duration(900).ease(d3.easeCubicOut).attr('stroke-dashoffset', 0);

          ['', 'Q1', 'Q2', 'Q3', 'Q4'].forEach(function (lab, i) {
            if (lab) g.append('text').attr('x', x(i)).attr('y', ih + 16).attr('text-anchor', 'middle').attr('fill', '#6f7785').attr('font-size', 9).text(lab);
          });

          (gm.plays || []).forEach(function (pl) {
            var cx = x(pl.qi), cy = y(gm.curve[pl.qi]);
            g.append('circle').attr('cx', cx).attr('cy', cy).attr('r', 0).attr('fill', '#0b0f17').attr('stroke', col).attr('stroke-width', 2.5).style('cursor', 'pointer')
              .on('mousemove', function (ev) { showTip('<b style="color:' + col + '">' + pl.player + '</b><br>' + pl.text, ev.pageX, ev.pageY); })
              .on('mouseout', hideTip)
              .transition().delay(700).duration(300).attr('r', 6);
            var tx = cx, anc = 'middle';
            if (pl.qi === 0) { tx = cx + 4; anc = 'start'; }
            if (pl.qi === 4) { tx = cx - 4; anc = 'end'; }
            g.append('text').attr('x', tx).attr('y', cy - 11).attr('text-anchor', anc).attr('fill', col).attr('font-size', 9).attr('font-weight', 700)
              .attr('opacity', 0).text(pl.tag).transition().delay(900).duration(300).attr('opacity', 1);
          });
        }

        function renderHeatmap(data) {
          var host = clear('kx-heat-chart'); if (!host || !window.d3) return;
          var rows = data.heat || []; if (!rows.length) return;
          var W = host.clientWidth || 880, ml = 138, mr = 14, mt = 26, rh = 30;
          var H = mt + rows.length * rh + 10;
          var iw = W - ml - mr;
          var svg = d3.select(host).append('svg').attr('viewBox', '0 0 ' + W + ' ' + H);
          var cw = iw / 5;
          var color = d3.scaleSequential(function (t) { return d3.interpolateRgb('#10151e', '#F58426')(t); }).domain([0, 40]);

          ['Game 1', 'Game 2', 'Game 3', 'Game 4', 'Game 5'].forEach(function (lab, i) {
            svg.append('text').attr('x', ml + cw * i + cw / 2).attr('y', mt - 10).attr('text-anchor', 'middle')
              .attr('fill', '#8b93a0').attr('font-size', 10).text(lab.replace('Game ', 'G'));
          });

          rows.forEach(function (row, r) {
            var y = mt + r * rh;
            svg.append('text').attr('x', ml - 10).attr('y', y + rh / 2 + 4).attr('text-anchor', 'end')
              .attr('fill', '#c6ccd5').attr('font-size', 11.5).text(row.name);
            row.cells.forEach(function (c, i) {
              var x = ml + cw * i;
              var dnp = (c.pts === null || c.pts === undefined);
              svg.append('rect').attr('x', x + 2).attr('y', y + 2).attr('width', cw - 4).attr('height', rh - 4).attr('rx', 3)
                .attr('fill', dnp ? '#0c1119' : color(c.pts)).attr('stroke', '#0b0f17').attr('stroke-width', 1).style('cursor', 'pointer')
                .attr('opacity', 0).transition().delay(i * 60 + r * 25).duration(300).attr('opacity', 1);
              svg.append('rect').attr('x', x + 2).attr('y', y + 2).attr('width', cw - 4).attr('height', rh - 4).attr('fill', 'transparent').style('cursor', 'pointer')
                .on('mousemove', function (ev) { showTip('<b style="color:#F58426">' + row.name + '</b><br>Game ' + (i + 1) + ': ' + (dnp ? 'DNP' : c.pts + ' pts · ' + c.fg + ' FG'), ev.pageX, ev.pageY); })
                .on('mouseout', hideTip);
              if (!dnp) {
                svg.append('text').attr('x', x + cw / 2).attr('y', y + rh / 2 + 4).attr('text-anchor', 'middle').style('pointer-events', 'none')
                  .attr('fill', c.pts >= 22 ? '#0b0f17' : '#e8eaed').attr('font-size', 11).attr('font-weight', c.pts >= 20 ? 800 : 500).text(c.pts);
              }
            });
          });
        }

        function renderFouls(data) {
          var host = clear('kx-fouls-chart'); if (!host || !window.d3) return;
          var rows = data.ft || []; if (!rows.length) return;
          var W = host.clientWidth || 880, H = 30 + rows.length * 46 + 12, mt = 30, rh = 46;
          var svg = d3.select(host).append('svg').attr('viewBox', '0 0 ' + W + ' ' + H);
          var cx = W / 2, maxv = d3.max(rows, function (d) { return Math.max(d.nyk, d.sas); });
          var sc = d3.scaleLinear().domain([0, maxv]).range([0, W / 2 - 60]);

          svg.append('text').attr('x', cx - 16).attr('y', 16).attr('text-anchor', 'end').attr('fill', '#8d99ae').attr('font-size', 10.5).attr('font-weight', 700).text('◀ Spurs trips (NY fouls)');
          svg.append('text').attr('x', cx + 16).attr('y', 16).attr('text-anchor', 'start').attr('fill', '#F58426').attr('font-size', 10.5).attr('font-weight', 700).text('Knicks trips ▶');

          rows.forEach(function (d, r) {
            var y = mt + r * rh, bh = 22;
            svg.append('line').attr('x1', cx).attr('x2', cx).attr('y1', y - 4).attr('y2', y + bh + 4).attr('stroke', '#3a475a');
            // Spurs (left, gray)
            svg.append('rect').attr('x', cx).attr('y', y).attr('height', bh).attr('width', 0).attr('fill', '#8d99ae').attr('rx', 2).style('cursor', 'pointer')
              .on('mousemove', function (ev) { showTip('<b style="color:#8d99ae">Spurs · Game ' + d.num + '</b><br>' + d.sas + ' free throws (fouls NY committed)', ev.pageX, ev.pageY); })
              .on('mouseout', hideTip)
              .transition().duration(700).delay(r * 80).attr('width', sc(d.sas)).attr('x', cx - sc(d.sas));
            // Knicks (right, orange)
            svg.append('rect').attr('x', cx).attr('y', y).attr('height', bh).attr('width', 0).attr('fill', '#F58426').attr('rx', 2).style('cursor', 'pointer')
              .on('mousemove', function (ev) { showTip('<b style="color:#F58426">Knicks · Game ' + d.num + '</b><br>' + d.nyk + ' free throws', ev.pageX, ev.pageY); })
              .on('mouseout', hideTip)
              .transition().duration(700).delay(r * 80).attr('width', sc(d.nyk));
            svg.append('text').attr('x', cx - sc(d.sas) - 6).attr('y', y + bh / 2 + 4).attr('text-anchor', 'end').attr('fill', '#aab0bb').attr('font-size', 11).attr('font-weight', 700).text(d.sas);
            svg.append('text').attr('x', cx + sc(d.nyk) + 6).attr('y', y + bh / 2 + 4).attr('text-anchor', 'start').attr('fill', '#ffb16b').attr('font-size', 11).attr('font-weight', 700).text(d.nyk);
            svg.append('text').attr('x', cx).attr('y', y + bh + 16).attr('text-anchor', 'middle').attr('fill', d.win ? '#6f7785' : '#ef476f').attr('font-size', 9.5).attr('font-weight', d.win ? 400 : 700).text('Game ' + d.num + (d.win ? '' : ' · L'));
          });
        }

        function renderQuarters(data) {
          var host = clear('kx-quarters-chart'); if (!host || !window.d3 || !data.quarters) return;
          var W = host.clientWidth || 880, H = 290, m = {t:24, r:14, b:36, l:32};
          var iw = W - m.l - m.r, ih = H - m.t - m.b;
          var svg = d3.select(host).append('svg').attr('viewBox', '0 0 ' + W + ' ' + H);
          var g = svg.append('g').attr('transform', 'translate(' + m.l + ',' + m.t + ')');
          var qs = [0, 1, 2, 3];
          var x0 = d3.scaleBand().domain(qs).range([0, iw]).padding(0.26);
          var x1 = d3.scaleBand().domain(['n', 's']).range([0, x0.bandwidth()]).padding(0.16);
          var maxv = d3.max(qs, function (i) { return Math.max(data.quarters.nyk[i], data.quarters.sas[i]); });
          var y = d3.scaleLinear().domain([0, maxv]).nice().range([ih, 0]);

          g.selectAll('.gd').data(y.ticks(5)).enter().append('line').attr('x1', 0).attr('x2', iw)
            .attr('y1', function (d) { return y(d); }).attr('y2', function (d) { return y(d); }).attr('stroke', '#161d29');
          g.selectAll('.yl').data(y.ticks(5)).enter().append('text').attr('x', -8).attr('y', function (d) { return y(d) + 3; })
            .attr('text-anchor', 'end').attr('fill', '#6f7785').attr('font-size', 10).text(function (d) { return d; });

          // legend
          svg.append('rect').attr('x', m.l).attr('y', 6).attr('width', 10).attr('height', 10).attr('fill', '#F58426').attr('rx', 2);
          svg.append('text').attr('x', m.l + 15).attr('y', 15).attr('fill', '#aab0bb').attr('font-size', 10).text('Knicks');
          svg.append('rect').attr('x', m.l + 64).attr('y', 6).attr('width', 10).attr('height', 10).attr('fill', '#8d99ae').attr('rx', 2);
          svg.append('text').attr('x', m.l + 79).attr('y', 15).attr('fill', '#aab0bb').attr('font-size', 10).text('Spurs');

          qs.forEach(function (qi, i) {
            var grp = g.append('g').attr('transform', 'translate(' + x0(qi) + ',0)');
            [['n', data.quarters.nyk[qi], '#F58426', 'Knicks'], ['s', data.quarters.sas[qi], '#8d99ae', 'Spurs']].forEach(function (pair) {
              grp.append('rect').attr('x', x1(pair[0])).attr('width', x1.bandwidth()).attr('y', ih).attr('height', 0).attr('fill', pair[2]).attr('rx', 2).style('cursor', 'pointer')
                .on('mousemove', function (ev) { showTip('<b style="color:' + pair[2] + '">' + pair[3] + '</b><br>Q' + (qi + 1) + ' total: ' + pair[1] + ' pts', ev.pageX, ev.pageY); })
                .on('mouseout', hideTip)
                .transition().duration(750).delay(i * 80).attr('y', y(pair[1])).attr('height', ih - y(pair[1]));
              grp.append('text').attr('x', x1(pair[0]) + x1.bandwidth() / 2).attr('y', y(pair[1]) - 4).attr('text-anchor', 'middle')
                .attr('fill', pair[2]).attr('font-size', 10).attr('font-weight', 700).attr('opacity', 0).text(pair[1])
                .transition().delay(i * 80 + 500).duration(300).attr('opacity', 1);
            });
            grp.append('text').attr('x', x0.bandwidth() / 2).attr('y', ih + 16).attr('text-anchor', 'middle').attr('fill', '#8b93a0').attr('font-size', 10).text('Q' + (qi + 1));
          });
        }

        function renderMargins(data) {
          var host = clear('kx-margins-chart'); if (!host || !window.d3 || !data.margins) return;
          var rows = data.margins;
          var W = host.clientWidth || 880, H = 270, m = {t:22, r:14, b:30, l:30};
          var iw = W - m.l - m.r, ih = H - m.t - m.b;
          var svg = d3.select(host).append('svg').attr('viewBox', '0 0 ' + W + ' ' + H);
          var g = svg.append('g').attr('transform', 'translate(' + m.l + ',' + m.t + ')');
          var x = d3.scaleBand().domain([1, 2, 3, 4, 5]).range([0, iw]).padding(0.4);
          var mx = d3.max(rows, function (d) { return Math.abs(d.margin); });
          var y = d3.scaleLinear().domain([-mx - 3, mx + 3]).range([ih, 0]);

          g.append('line').attr('x1', 0).attr('x2', iw).attr('y1', y(0)).attr('y2', y(0)).attr('stroke', '#3a475a');

          rows.forEach(function (d, i) {
            var col = d.win ? '#F58426' : '#ef476f';
            var top = Math.min(y(d.margin), y(0)), h = Math.abs(y(d.margin) - y(0));
            g.append('rect').attr('x', x(d.num)).attr('width', x.bandwidth()).attr('y', y(0)).attr('height', 0).attr('fill', col).attr('rx', 2).style('cursor', 'pointer')
              .on('mousemove', function (ev) { showTip('<b style="color:' + col + '">Game ' + d.num + '</b><br>' + (d.margin > 0 ? 'Knicks by ' + d.margin : 'Spurs by ' + (-d.margin)), ev.pageX, ev.pageY); })
              .on('mouseout', hideTip)
              .transition().duration(700).delay(i * 90).attr('y', top).attr('height', h);
            g.append('text').attr('x', x(d.num) + x.bandwidth() / 2).attr('y', d.margin > 0 ? y(d.margin) - 6 : y(d.margin) + 15).attr('text-anchor', 'middle')
              .attr('fill', col).attr('font-size', 12).attr('font-weight', 800).attr('opacity', 0).text((d.margin > 0 ? '+' : '') + d.margin)
              .transition().delay(i * 90 + 450).duration(300).attr('opacity', 1);
            g.append('text').attr('x', x(d.num) + x.bandwidth() / 2).attr('y', y(0) + (d.margin >= 0 ? 15 : -8)).attr('text-anchor', 'middle').attr('fill', '#6f7785').attr('font-size', 10).text('G' + d.num);
          });
        }

        // Reusable half-court (basket at top) for the play animations.
        function buildCourt(hostId) {
          var host = clear(hostId); if (!host || !window.d3) return null;
          var VB = 360, VBH = 300;
          var svg = d3.select(host).append('svg').attr('viewBox', '0 0 ' + VB + ' ' + VBH);
          var court = svg.append('g').attr('fill', 'none').attr('stroke', '#26303f').attr('stroke-width', 1.5);
          court.append('rect').attr('x', 1).attr('y', 1).attr('width', VB - 2).attr('height', VBH - 2).attr('rx', 8).attr('stroke', '#1d2532');
          court.append('rect').attr('x', 150).attr('y', 18).attr('width', 60).attr('height', 132);
          court.append('circle').attr('cx', 180).attr('cy', 150).attr('r', 30);
          court.append('path').attr('d', 'M28,86 Q180,300 332,86');
          svg.append('line').attr('x1', 164).attr('y1', 18).attr('x2', 196).attr('y2', 18).attr('stroke', '#6f7785').attr('stroke-width', 2.5);
          svg.append('circle').attr('cx', 180).attr('cy', 27).attr('r', 7).attr('fill', 'none').attr('stroke', '#F58426').attr('stroke-width', 2);
          var cap = svg.append('text').attr('x', 180).attr('y', 288).attr('text-anchor', 'middle').attr('fill', '#e8eaed').attr('font-size', 12).attr('font-weight', 700).attr('opacity', 0);
          var clk = svg.append('text').attr('x', 332).attr('y', 26).attr('text-anchor', 'end').attr('fill', '#8b93a0').attr('font-size', 13).attr('font-family', 'monospace').attr('font-weight', 700).text('1.2').attr('opacity', 0);
          function player(x, y, label, color) {
            var gg = svg.append('g');
            gg.append('circle').attr('cx', x).attr('cy', y).attr('r', 8).attr('fill', color).attr('stroke', '#0b0f17').attr('stroke-width', 1.5);
            gg.append('text').attr('x', x).attr('y', y + 22).attr('text-anchor', 'middle').attr('fill', color).attr('font-size', 10).attr('font-weight', 800).text(label);
            return gg;
          }
          var ball = svg.append('circle').attr('r', 5.5).attr('fill', '#F58426').attr('stroke', '#7a3d10').attr('stroke-width', 1).attr('opacity', 0);
          function ballAt(x, y) { ball.attr('transform', 'translate(' + x + ',' + y + ')'); }
          function ballAlong(pathStr, dur, ease, cb) {
            var tmp = svg.append('path').attr('d', pathStr).attr('fill', 'none').attr('stroke', 'none');
            var L = tmp.node().getTotalLength();
            ball.transition().duration(dur).ease(ease || d3.easeQuadOut)
              .attrTween('transform', function () { return function (t) { var pt = tmp.node().getPointAtLength(t * L); return 'translate(' + pt.x + ',' + pt.y + ')'; }; })
              .on('end', function () { tmp.remove(); if (cb) cb(); });
          }
          function flash(text, color) { cap.interrupt().attr('fill', color || '#e8eaed').attr('font-size', 12).text(text).attr('opacity', 0).transition().duration(180).attr('opacity', 1); }
          return { svg: svg, cap: cap, clk: clk, ball: ball, player: player, ballAt: ballAt, ballAlong: ballAlong, flash: flash };
        }

        var missTimer;
        function renderMiss() {
          if (missTimer) { clearTimeout(missTimer); missTimer = null; }
          var c = buildCourt('kx-miss-chart'); if (!c) return;
          c.clk.text('0.4');
          c.player(185, 212, 'WEMBANYAMA', '#cbd2da');
          c.ballAt(185, 212);
          c.ball.transition().delay(350).duration(1).attr('opacity', 1).on('end', function () {
            c.clk.transition().duration(200).attr('opacity', 1);
            c.flash('Wembanyama for the win…', '#8b93a0');
            c.ballAlong('M185,212 Q176,44 184,33', 900, d3.easeQuadOut, function () {
              c.flash('OFF THE RIM', '#ef476f');
              c.ballAlong('M184,33 Q148,42 92,150', 650, d3.easeQuadIn, function () {
                c.ball.transition().duration(250).attr('opacity', 0);
                c.cap.transition().delay(150).duration(220).attr('opacity', 0).on('end', function () {
                  c.cap.attr('fill', '#F58426').attr('font-size', 13.5).text('NO GOOD — KNICKS WIN 105-104').transition().duration(320).attr('opacity', 1);
                  missTimer = setTimeout(renderMiss, 2600);
                });
              });
            });
          });
        }
        window.kxReplayMiss = renderMiss;

        var climbTimer;
        function renderClimb() {
          if (climbTimer) { clearTimeout(climbTimer); climbTimer = null; }
          var host = clear('kx-climb-chart'); if (!host || !window.d3) return;
          var W = 360, H = 210, cx = W / 2;
          var svg = d3.select(host).append('svg').attr('viewBox', '0 0 ' + W + ' ' + H);
          svg.append('text').attr('x', cx).attr('y', 28).attr('text-anchor', 'middle').attr('fill', '#8b93a0').attr('font-size', 12).attr('font-weight', 800).attr('letter-spacing', '2').text('GAME 4 · 3RD QUARTER');
          var num = svg.append('text').attr('x', cx).attr('y', 102).attr('text-anchor', 'middle').attr('font-size', 64).attr('font-weight', 900).attr('fill', '#ef476f').text('-29');
          var tx0 = 44, tx1 = W - 44, ty = 134;
          var scale = d3.scaleLinear().domain([-30, 6]).range([tx0, tx1]);
          var origin = scale(0);
          svg.append('line').attr('x1', tx0).attr('x2', tx1).attr('y1', ty).attr('y2', ty).attr('stroke', '#1d2532').attr('stroke-width', 8).attr('stroke-linecap', 'round');
          svg.append('line').attr('x1', origin).attr('x2', origin).attr('y1', ty - 9).attr('y2', ty + 9).attr('stroke', '#3a475a').attr('stroke-width', 2);
          var bar = svg.append('line').attr('y1', ty).attr('y2', ty).attr('x1', origin).attr('x2', origin).attr('stroke', '#ef476f').attr('stroke-width', 8).attr('stroke-linecap', 'round');
          var score = svg.append('text').attr('x', cx).attr('y', 174).attr('text-anchor', 'middle').attr('fill', '#cdd2d9').attr('font-size', 16).attr('font-weight', 700).text('SPURS 81 — KNICKS 52');
          var cap = svg.append('text').attr('x', cx).attr('y', 198).attr('text-anchor', 'middle').attr('fill', '#6f7785').attr('font-size', 11).attr('font-weight', 700).attr('opacity', 0).text('LARGEST COMEBACK IN FINALS HISTORY');
          function upd(v) { var col = v >= 0 ? '#F58426' : '#ef476f'; num.attr('fill', col).text((v > 0 ? '+' : '') + Math.round(v)); bar.attr('stroke', col).attr('x2', scale(v)); }
          num.transition().delay(550).duration(2600).ease(d3.easeCubicInOut)
            .tween('m', function () { var i = d3.interpolateNumber(-29, 1); return function (t) { upd(i(t)); }; })
            .on('end', function () {
              upd(1);
              score.transition().duration(320).attr('fill', '#fff').text('KNICKS 107 — SPURS 106');
              cap.transition().delay(120).duration(320).attr('opacity', 1).attr('fill', '#F58426');
              climbTimer = setTimeout(renderClimb, 2800);
            });
        }

        var fortyTimer;
        function renderForty() {
          if (fortyTimer) { clearTimeout(fortyTimer); fortyTimer = null; }
          var host = clear('kx-forty-chart'); if (!host || !window.d3) return;
          var W = 360, H = 210, cx = W / 2;
          var svg = d3.select(host).append('svg').attr('viewBox', '0 0 ' + W + ' ' + H);
          svg.append('text').attr('x', cx).attr('y', 28).attr('text-anchor', 'middle').attr('fill', '#8b93a0').attr('font-size', 12).attr('font-weight', 800).attr('letter-spacing', '2').text('GAME 5 · FINALS MVP');
          var num = svg.append('text').attr('x', cx).attr('y', 104).attr('text-anchor', 'middle').attr('font-size', 70).attr('font-weight', 900).attr('fill', '#F58426').text('0');
          var tx0 = 44, tx1 = W - 44, ty = 138;
          var scale = d3.scaleLinear().domain([0, 47]).range([tx0, tx1]);
          svg.append('line').attr('x1', tx0).attr('x2', tx1).attr('y1', ty).attr('y2', ty).attr('stroke', '#1d2532').attr('stroke-width', 8).attr('stroke-linecap', 'round');
          var bar = svg.append('line').attr('y1', ty).attr('y2', ty).attr('x1', tx0).attr('x2', tx0).attr('stroke', '#F58426').attr('stroke-width', 8).attr('stroke-linecap', 'round');
          var rx = scale(38);
          svg.append('line').attr('x1', rx).attr('x2', rx).attr('y1', ty - 11).attr('y2', ty + 11).attr('stroke', '#8d99ae').attr('stroke-width', 2);
          svg.append('text').attr('x', rx).attr('y', ty + 26).attr('text-anchor', 'middle').attr('fill', '#8d99ae').attr('font-size', 10).attr('font-weight', 700).text("Reed '70 · 38");
          var rec = svg.append('text').attr('x', cx).attr('y', 182).attr('text-anchor', 'middle').attr('fill', '#ffd166').attr('font-size', 13).attr('font-weight', 800).attr('opacity', 0).text('FRANCHISE FINALS RECORD');
          svg.append('text').attr('x', cx).attr('y', 202).attr('text-anchor', 'middle').attr('fill', '#6f7785').attr('font-size', 11).attr('font-weight', 700).text('45 PTS · 13 STRAIGHT IN THE 4TH');
          function upd(v) { var n = Math.round(v); num.text(n).attr('fill', n >= 38 ? '#ffd166' : '#F58426'); bar.attr('x2', scale(v)).attr('stroke', v >= 38 ? '#ffd166' : '#F58426'); }
          num.transition().delay(450).duration(2200).ease(d3.easeCubicOut)
            .tween('m', function () { var i = d3.interpolateNumber(0, 45); return function (t) { upd(i(t)); }; })
            .on('end', function () { upd(45); rec.transition().duration(320).attr('opacity', 1); fortyTimer = setTimeout(renderForty, 2800); });
        }

        var shotTimer;
        function renderShot() {
          if (shotTimer) { clearTimeout(shotTimer); shotTimer = null; }
          var host = clear('kx-shot-chart'); if (!host || !window.d3) return;
          var VB = 360, VBH = 300;
          var svg = d3.select(host).append('svg').attr('viewBox', '0 0 ' + VB + ' ' + VBH);
          var court = svg.append('g').attr('fill', 'none').attr('stroke', '#26303f').attr('stroke-width', 1.5);
          court.append('rect').attr('x', 1).attr('y', 1).attr('width', VB - 2).attr('height', VBH - 2).attr('rx', 8).attr('stroke', '#1d2532');
          court.append('rect').attr('x', 150).attr('y', 18).attr('width', 60).attr('height', 132);
          court.append('circle').attr('cx', 180).attr('cy', 150).attr('r', 30);
          court.append('path').attr('d', 'M28,86 Q180,300 332,86');
          svg.append('line').attr('x1', 164).attr('y1', 18).attr('x2', 196).attr('y2', 18).attr('stroke', '#6f7785').attr('stroke-width', 2.5);
          svg.append('circle').attr('cx', 180).attr('cy', 27).attr('r', 7).attr('fill', 'none').attr('stroke', '#F58426').attr('stroke-width', 2);

          function player(x, y, label, color) {
            var gg = svg.append('g');
            gg.append('circle').attr('cx', x).attr('cy', y).attr('r', 8).attr('fill', color).attr('stroke', '#0b0f17').attr('stroke-width', 1.5);
            gg.append('text').attr('x', x).attr('y', y + 22).attr('text-anchor', 'middle').attr('fill', color).attr('font-size', 10).attr('font-weight', 800).text(label);
            return gg;
          }
          player(250, 214, 'BRUNSON', '#cbd2da');
          var og = player(160, 54, 'ANUNOBY', '#F58426');
          var clk = svg.append('text').attr('x', 332).attr('y', 26).attr('text-anchor', 'end').attr('fill', '#8b93a0').attr('font-size', 13).attr('font-family', 'monospace').attr('font-weight', 700).text('1.2').attr('opacity', 0);
          var cap = svg.append('text').attr('x', 180).attr('y', 288).attr('text-anchor', 'middle').attr('fill', '#e8eaed').attr('font-size', 12).attr('font-weight', 700).attr('opacity', 0);
          var ball = svg.append('circle').attr('r', 5.5).attr('fill', '#F58426').attr('stroke', '#7a3d10').attr('stroke-width', 1).attr('transform', 'translate(250,214)').attr('opacity', 0);

          function ballAlong(pathStr, dur, ease, cb) {
            var tmp = svg.append('path').attr('d', pathStr).attr('fill', 'none').attr('stroke', 'none');
            var L = tmp.node().getTotalLength();
            ball.transition().duration(dur).ease(ease || d3.easeQuadOut)
              .attrTween('transform', function () { return function (t) { var pt = tmp.node().getPointAtLength(t * L); return 'translate(' + pt.x + ',' + pt.y + ')'; }; })
              .on('end', function () { tmp.remove(); if (cb) cb(); });
          }
          function flash(text, color) { cap.interrupt().attr('fill', color || '#e8eaed').attr('font-size', 12).text(text).attr('opacity', 0).transition().duration(180).attr('opacity', 1); }

          ball.transition().delay(350).duration(1).attr('opacity', 1).on('end', function () {
            clk.transition().duration(200).attr('opacity', 1);
            flash('Brunson lets it fly…', '#8b93a0');
            ballAlong('M250,214 Q204,52 187,34', 850, d3.easeQuadOut, function () {
              flash('OFF THE FRONT RIM', '#ef476f');
              ballAlong('M187,34 Q182,28 176,50', 260, d3.easeQuadIn, function () {
                og.transition().duration(180).attr('transform', 'translate(0,-9)');
                ballAlong('M176,50 Q180,30 180,27', 320, d3.easeQuadOut, function () {
                  flash('ANUNOBY TIPS IT IN — 1.2 LEFT', '#F58426');
                  ballAlong('M180,27 L180,72', 320, d3.easeQuadIn, function () {
                    ball.transition().duration(200).attr('opacity', 0);
                    cap.transition().delay(280).duration(220).attr('opacity', 0).on('end', function () {
                      cap.attr('fill', '#F58426').attr('font-size', 13.5).text('KNICKS 107 — SPURS 106').transition().duration(320).attr('opacity', 1);
                      shotTimer = setTimeout(renderShot, 2400);
                    });
                  });
                });
              });
            });
          });
        }
        window.kxReplayShot = renderShot;

        var deckBound = false, deckIdx = 0;
        function isMobile() { return window.matchMedia('(max-width: 680px)').matches; }
        function setupDeck() {
          var deck = document.getElementById('kx-deck'); if (!deck) return;
          var cards = [].slice.call(deck.querySelectorAll(':scope > .kx-card'));
          var prev = document.getElementById('kx-prev'), next = document.getElementById('kx-next');
          var fill = document.getElementById('kx-prog-fill'), count = document.getElementById('kx-count');
          var n = cards.length;
          deck.classList.toggle('is-mobile', isMobile());

          function transitions(on) { cards.forEach(function (c) { c.style.transition = on ? '' : 'none'; }); }
          function place(dxPx) {
            cards.forEach(function (c, i) {
              c.style.transform = 'translate3d(calc(' + ((i - deckIdx) * 100) + '% + ' + (dxPx || 0) + 'px), 0, 0)';
            });
          }
          function paint() {
            cards.forEach(function (c, i) { c.style.pointerEvents = i === deckIdx ? 'auto' : 'none'; });
            if (cards[deckIdx]) cards[deckIdx].scrollTop = 0;
            if (fill) fill.style.width = ((deckIdx + 1) / n * 100) + '%';
            if (count) count.textContent = (deckIdx + 1) + ' / ' + n;
            if (prev) prev.disabled = deckIdx === 0;
            if (next) next.disabled = deckIdx === n - 1;
          }
          function layout() { place(0); paint(); }
          function move(d) {
            var ni = Math.max(0, Math.min(n - 1, deckIdx + d));
            if (ni === deckIdx) { transitions(true); place(0); return; }
            deckIdx = ni; transitions(true); place(0); paint();
          }
          deck.__layout = layout;

          if (isMobile()) { transitions(true); layout(); }
          else { cards.forEach(function (c) { c.style.transform = ''; c.style.transition = ''; c.style.pointerEvents = ''; }); }

          if (!deckBound) {
            deckBound = true;
            if (prev) prev.addEventListener('click', function () { move(-1); });
            if (next) next.addEventListener('click', function () { move(1); });

            var sx = 0, sy = 0, drag = false, decided = false, horiz = false, w = 0;
            deck.addEventListener('touchstart', function (e) {
              if (!isMobile()) return;
              sx = e.touches[0].clientX; sy = e.touches[0].clientY; drag = true; decided = false; horiz = false; w = deck.clientWidth || 1;
            }, {passive: true});
            deck.addEventListener('touchmove', function (e) {
              if (!drag || !isMobile()) return;
              var dx = e.touches[0].clientX - sx, dy = e.touches[0].clientY - sy;
              if (!decided) {
                if (Math.abs(dx) < 6 && Math.abs(dy) < 6) return;
                decided = true; horiz = Math.abs(dx) > Math.abs(dy);
                if (horiz) transitions(false);
              }
              if (horiz) {
                e.preventDefault();
                var d = dx;
                if ((deckIdx === 0 && d > 0) || (deckIdx === n - 1 && d < 0)) d *= 0.32; // rubber-band at the ends
                place(d);
              }
            }, {passive: false});
            deck.addEventListener('touchend', function (e) {
              if (!drag) return; drag = false;
              if (!horiz) return;
              transitions(true);
              var dx = e.changedTouches[0].clientX - sx;
              var threshold = Math.min(72, w * 0.2);
              if (Math.abs(dx) > threshold) { deckIdx = Math.max(0, Math.min(n - 1, deckIdx + (dx < 0 ? 1 : -1))); }
              place(0); paint();
            }, {passive: true});
          }
        }

        function renderAll() {
          var el = document.getElementById('kx-data'); if (!el || !window.d3) return;
          var data; try { data = JSON.parse(el.dataset.kx); } catch (e) { return; }
          renderHero(data); renderShot(); renderMiss(); renderClimb(); renderForty();
          renderQuarters(data); renderMargins(data);
          renderDuel(data); renderHeatmap(data); renderFouls(data);
          (data.games || []).forEach(renderMomentum);
        }

        var rt;
        function go() { renderAll(); setupDeck(); }
        window.addEventListener('resize', function () { clearTimeout(rt); rt = setTimeout(go, 220); });
        window.addEventListener('phx:page-loading-stop', go);
        if (document.readyState !== 'loading') go(); else document.addEventListener('DOMContentLoaded', go);
      })();
    </script>
    """
  end

  defp render_leaders(assigns) do
    ~H"""
    <table class="kx-stats">
      <thead>
        <tr>
          <th class="nm">Player</th>
          <th>GP</th><th>PPG</th><th>RPG</th><th>APG</th><th>FG%</th><th>3PT%</th>
        </tr>
      </thead>
      <tbody>
        <%= for l <- @leaders do %>
          <tr>
            <td class="nm">{l.name}</td>
            <td>{l.gp}</td>
            <td class="pts">{f1(l.ppg)}</td>
            <td>{f1(l.rpg)}</td>
            <td>{f1(l.apg)}</td>
            <td>{l.fg_pct}</td>
            <td>{l.tp_pct}</td>
          </tr>
        <% end %>
      </tbody>
    </table>
    """
  end

end
