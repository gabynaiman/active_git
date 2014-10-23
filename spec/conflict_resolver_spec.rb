require 'minitest_helper'

describe ActiveGit::ConflictResolver do

  it 'Both added keys' do
    base   = {name: 'Argentina'}
    ours   = {name: 'Argentina', gmt: '-0300'}
    theirs = {name: 'Argentina', code: 'AR'}

    merged = ActiveGit::ConflictResolver.resolve base, ours, theirs

    merged.must_equal name: 'Argentina', code: 'AR', gmt: '-0300'
  end

  it 'Both modify diferent keys' do
    base   = {name: 'Argentina', code: 'XX', gmt: '-0000'}
    ours   = {name: 'Argentina', code: 'XX', gmt: '-0300'}
    theirs = {name: 'Argentina', code: 'AR', gmt: '-0000'}

    merged = ActiveGit::ConflictResolver.resolve base, ours, theirs

    merged.must_equal name: 'Argentina', code: 'AR', gmt: '-0300'
  end

  it 'One added and other removed keys' do
    base   = {name: 'Argentina', code: 'AR'}
    ours   = {name: 'Argentina', code: 'AR', gmt: '-0300'}
    theirs = {name: 'Argentina'}

    merged = ActiveGit::ConflictResolver.resolve base, ours, theirs

    merged.must_equal name: 'Argentina', gmt: '-0300'
  end

  it 'Both update same key' do
    base   = {name: 'Argentina'}
    ours   = {name: 'Uruguay'}
    theirs = {name: 'Brasil'}

    merged = ActiveGit::ConflictResolver.resolve base, ours, theirs

    merged.must_equal name: 'Uruguay'
  end

  it 'Without base' do
    base   = {}
    ours   = {name: 'Argentina', code: 'AR'}
    theirs = {name: 'Argentina', gmt: '-0300'}

    merged = ActiveGit::ConflictResolver.resolve base, ours, theirs

    merged.must_equal name: 'Argentina', code: 'AR', gmt: '-0300'
  end

end