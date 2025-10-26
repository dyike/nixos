{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ git git-lfs delta ];

  environment.etc."gitconfig".text = ''
    [user]
      name = dyike
      email = yuanfeng634@gmail.com

    [init]
      defaultBranch = main
    [push]
      autoSetupRemote = true
    [pull]
      rebase = false

    [core]
      quotepath = false
    [i18n]
      commitEncoding = utf-8
      logOutputEncoding = utf-8
    [gui]
      encoding = utf-8

    [includeIf "gitdir:~/work/"]
      path = ~/work/.gitconfig

    [alias]
      br = branch
      co = checkout
      st = status
      ls = log --pretty=format:"%C(yellow)%h%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate
      ll = log --pretty=format:"%C(yellow)%h%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate --numstat
      cm = commit -m
      ca = commit -am
      dc = diff --cached
      amend = commit --amend -m
      update = submodule update --init --recursive
      foreach = submodule foreach
  '';
}
