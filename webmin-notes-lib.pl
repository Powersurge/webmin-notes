use WebminCore;
init_config();

sub list_notes
{
    my @rv;
    my $lnum = 0;

    open(CONF, $config{'notes_conf'});

    while(<CONF>) {
        s/\r//g;     # remove carriage returns only
        chomp;       # remove newline at end of line
        s/#.*$//;    # remove comments

        my ($status, $style, $title, $content) = split(/\|/, $_, 4);  # split max 4 parts

        if(defined $content){
            $content =~ s/\\n/\n/g;  # unescape newlines
            push(@rv, { 
                'status' => $status,
                'style' => $style,
                'title' => $title,
                'content' => $content,
                'line' => $lnum 
            });
        }
        $lnum++;
    }
    close(CONF);

    # Sort notes alphabetically by title (case-insensitive)
    @rv = sort { lc($a->{'title'}) cmp lc($b->{'title'}) } @rv;

    return @rv;
}

sub create_note
{
    my ($note) = @_;
    my $content = $note->{'content'};
    $content =~ s/\n/\\n/g;   # Escape newlines
    open_tempfile(CONF, ">>$config{'notes_conf'}");
    print_tempfile(CONF, $note->{'status'}."|".$note->{'style'}."|".$note->{'title'}."|".$content."\n");
    close_tempfile(CONF);
}

sub modify_note
{
    my ($note) = @_;
    my $content = $note->{'content'};
    $content =~ s/\n/\\n/g;   # Escape newlines
    my $lref = read_file_lines($config{'notes_conf'});
    $lref->[$note->{'line'}] = $note->{'status'}."|".$note->{'style'}."|".$note->{'title'}."|".$content;
    flush_file_lines($config{'notes_conf'});
}

sub delete_note
{
	my ($note) = @_;
	my $lref = read_file_lines($config{'notes_conf'});
	splice(@$lref, $note->{'line'}, 1);
	flush_file_lines($config{'notes_conf'});
}


sub apply_configuration
{
   kill_byname_logged('HUP', 'noted');
}

1;

